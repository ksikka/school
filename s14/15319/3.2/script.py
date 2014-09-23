#!/usr/bin/env python
"""
@ksikka

Set these environment variables:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
"""

import sys
import boto
if boto.__version__ != '2.25.0':
  print "Detected boto version %s. Please use version 2.25.0 instead." % boto.__version__
  sys.exit(1)

from boto.ec2.autoscale import AutoScalingGroup, LaunchConfiguration, ScalingPolicy, Tag
from boto.ec2.cloudwatch import MetricAlarm
from boto.exception import BotoServerError


# Configuration
name = "ProjTwoPointFour" # used for elb and as_group
sec_groups = ["launch-wizard-2"]
ami = "ami-99e2d4f0"
key = "cc"
instance_type = "m1.small"
sns_arn = "arn:aws:sns:us-east-1:688252320771:Project-2-4"


# Create connections to Auto Scaling and CloudWatch
as_conn = boto.ec2.autoscale.connect_to_region("us-east-1")
cw_conn = boto.ec2.cloudwatch.connect_to_region("us-east-1")
elbconn = boto.ec2.elb.connect_to_region('us-east-1')


# Create Load Balancer (HTTP 80 and HTTP 8080, healthcheck HTTP 8080)
def create_elb():
    try:
        elb = elbconn.get_all_load_balancers(name)[0]
    except BotoServerError, e:
        if e.error_code == u'LoadBalancerNotFound':
            elb = elbconn.create_load_balancer(name, ['us-east-1b'], [(8080, 8080, 'http'), (80, 80, 'http')])
        else:
            raise
    else:
        print "Warning: Load Balancer already exists"
    return elb


# Create launch configuration
def create_launch_config():
    lc = LaunchConfiguration(name=name,
                             image_id=ami,
                             key_name=key,
                             security_groups=sec_groups,
                             instance_type=instance_type,
                             instance_monitoring=True)
    try:
        as_conn.create_launch_configuration(lc)
    except BotoServerError, e:
        if e.error_code == u'AlreadyExists':
            print "Warning: Launch Config already exists"
        else:
            raise
    return lc

# Create Auto Scaling group
def create_as_group(lc):
    ag = AutoScalingGroup(group_name=name,
                          availability_zones=["us-east-1b"],
                          launch_config=lc,
                          min_size=2,
                          max_size=5,
                          load_balancers=(name,),
                          connection=as_conn)
 
    try:
        as_conn.create_auto_scaling_group(ag)
    except BotoServerError, e:
        if e.error_code == u'AlreadyExists':
            print "Warning: Autoscaling Group already exists"
        else:
            raise

    # Fetch the autoscale group after it is created
    ag = as_conn.get_all_groups(names=[name])[0]

    # Create a Tag for the austoscale group
    as_tag = Tag(key='Project',
                 value = '2.4',
                 propagate_at_launch=True,
                 resource_id=name)

    # Add the tag to the autoscale group
    as_conn.create_or_update_tags([as_tag])

    # Email notifications
    as_conn.put_notification_configuration(ag, sns_arn, ['autoscaling:EC2_INSTANCE_LAUNCH',
                                                         'autoscaling:EC2_INSTANCE_LAUNCH_ERROR',
                                                         'autoscaling:EC2_INSTANCE_TERMINATE',
                                                         'autoscaling:EC2_INSTANCE_TERMINATE_ERROR',
                                                         'autoscaling:TEST_NOTIFICATION'])

    return ag


# Create scaling policies
def create_scaling_policies():
    scale_up_policy = ScalingPolicy(
        name='scale_up', adjustment_type='ChangeInCapacity',
        as_name=name, scaling_adjustment=1)

    scale_down_policy = ScalingPolicy(
        name='scale_down', adjustment_type='ChangeInCapacity',
        as_name=name, scaling_adjustment=-1)

    as_conn.create_scaling_policy(scale_up_policy)
    as_conn.create_scaling_policy(scale_down_policy)

    scale_up_policy = as_conn.get_all_policies(
        as_group=name, policy_names=['scale_up'])[0]

    scale_down_policy = as_conn.get_all_policies(
        as_group=name, policy_names=['scale_down'])[0]

    return (scale_up_policy, scale_down_policy)


def create_metric_alarms(scale_up_policy, scale_down_policy):
    """
    Scale up when the group's CPU load exceeds 80% on average over a 5 minute interval.
    Scale down when the group's CPU load is below 20% on average over a 5 minute interval.
    """
    # Monitor instances within the Auto Scaling group cluster
    alarm_dimensions_as = {"AutoScalingGroupName": name}

    # Create metric alarms
    scale_up_alarm = MetricAlarm(
        name='scale_up_on_cpu_' + name, namespace='AWS/EC2',
        metric='CPUUtilization', statistic='Average',
        comparison='>', threshold=80,
        period=(60 * 5), evaluation_periods=1,
        alarm_actions=[scale_up_policy.policy_arn],
        dimensions=alarm_dimensions_as)

    scale_down_alarm = MetricAlarm(
        name='scale_down_on_cpu_' + name, namespace='AWS/EC2',
        metric='CPUUtilization', statistic='Average',
        comparison='<', threshold=20,
        period=(60 * 5), evaluation_periods=1,
        alarm_actions=[scale_down_policy.policy_arn],
        dimensions=alarm_dimensions_as)

    # Create alarms in CloudWatch
    cw_conn.create_alarm(scale_up_alarm)
    cw_conn.create_alarm(scale_down_alarm)

    return (scale_up_alarm, scale_down_alarm)


if __name__ == "__main__":
    print "Setting up autoscaling."

    print "Info: Creating ELB..."
    elb = create_elb()
    print "Info: done"

    print "Info: Creating Launch Config..."
    lc = create_launch_config()
    print "Info: done"

    print "Info: Creating AutoScaling Group..."
    ag = create_as_group(lc)
    print "Info: done"

    print "Info: Creating Scaling Policies..."
    scale_up_policy, scale_down_policy = create_scaling_policies()
    print "Info: done"

    print "Info: Creating CloudWatch Alarms..."
    create_metric_alarms(scale_up_policy, scale_down_policy)
    print "Info: done"

