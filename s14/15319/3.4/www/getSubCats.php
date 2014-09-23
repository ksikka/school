<?php
header('Content-Type: application/json; charset=utf-8');

// display extra errors 
//error_reporting(E_ALL);
//ini_set('display_errors', 'On');

//check and set parameters
$rangeRequested = false;
if ( array_key_exists('cat', $_GET) ) {
        $cat=$_GET["cat"];
} else {
        echo "'cat=' Category parameter required.";
        exit;
}

// Include the AWS SDK using the Composer autoloader
require 'vendor/autoload.php';

use Aws\DynamoDb\DynamoDbClient;
use Aws\DynamoDb\Enum\ComparisonOperator;
use Aws\DynamoDb\Enum\Type;
use Aws\Common\Enum\Region;

// Instantiate the DynamoDB client with your AWS credentials
$aws = Aws\Common\Aws::factory('./config.php');
$client = $aws->get('dynamodb');

	//echo "multiple..." . PHP_EOL;
	try {
	$response = $client->query(array(
	    "TableName" => "Proj34Cats",
	    "HashKeyValue" => array(Type::STRING => "lolol"),
	    "RangeKeyCondition" => array(
	        "ComparisonOperator" => ComparisonOperator::EQ,
	        "AttributeValueList" => array(
              array(Type::STRING => "$cat")
	        )
	    )
	));

        } catch (DynamoDbException $e) {
          echo 'The items could not be retrieved.';
        }

	//check for "no Items found" case
	if ( count($response["Items"]) == 0 ) {
		echo "[]";
		exit;
	}

	//print_r ($response["Items"]);
	//echo "Count = " . $response["Count"] . PHP_EOL;
	foreach ($response["Items"] as $item) {
		echo json_encode($item["subcategories"]["SS"]);
	}

/*
} else {	//single image = getItem()

	try {
	$response = $client->getItem(array(
	    "TableName" => "Proj34",
	    "Key" => array(
	       "HashKeyElement" => array(Type::STRING => "$cat"),
	       "RangeKeyElement" => array(Type::NUMBER => "$pic")
	    )
	));

	} catch (DynamoDbException $e) {
	  echo 'The item could not be retrieved.';
	}

        //check for "no Items found" case
        if ( count($response["Item"]) == 0 ) {
                echo "No Item matches your query." . PHP_EOL;
                exit;
        }

	//print_r ( $response["Item"] );
	echo "<p>" . PHP_EOL;
	echo "<img src=\"" . $response["Item"]["S3URL"]["S"] . "\" title=\"" 
		. $response["Item"]["Category"]["S"] . " #" . $response["Item"]["Picture"]["N"] 
		. "\" >" . PHP_EOL;
	echo "</p>" . PHP_EOL;
	//echo "\n consumed: " . $response["ConsumedCapacityUnits"];
}
 */


?>
