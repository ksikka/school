/***************************************************************************
* ======================================================================
* Computer Vision/Image Processing Tool Project - Dr. Scott Umbaugh SIUE
* ======================================================================
*
*             File Name: CVIPtexture.h
*           Description: contains function prototypes, type names, constants,
*			 etc. related to libdataserv (Data Services Toolkit.)
*         Related Files: Imakefile, cvip_pgmtexture.c
*   Initial Coding Date: 6/19/96
*           Portability: Standard (ANSI) C
*             Credit(s): Steve Costello
*                        Southern Illinois University @ Edwardsville
*
** Copyright (C) 1993 SIUE - by Gregory Hance.
**
** Permission to use, copy, modify, and distribute this software and its
** documentation for any purpose and without fee is hereby granted, provided
** that the above copyright notice appear in all copies and that both that
** copyright notice and this permission notice appear in supporting
** documentation.  This software is provided "as is" without express or
** implied warranty.
**
****************************************************************************/

typedef struct  {
/* [0 - 12] -> 13 directions in a 3D image
   [13] -> average, [14] -> range (max - min) */
	float ASM[15];		/*  (1) Angular Second Moment */
	float contrast[15];	/*  (2) Contrast */
	float correlation[15];	/*  (3) Correlation */
	float variance[15];	/*  (4) Variance */
	float IDM[15];		/*  (5) Inverse Diffenence Moment */
	float sum_avg[15];	/*  (6) Sum Average */
	float sum_var[15];	/*  (7) Sum Variance */
	float sum_entropy[15];	/*  (8) Sum Entropy */
	float entropy[15];	/*  (9) Entropy */
	float diff_var[15];	/* (10) Difference Variance */
	float diff_entropy[15];	/* (11) Diffenence Entropy */
	float meas_corr1[15];	/* (12) Measure of Correlation 1 */
	float meas_corr2[15];	/* (13) Measure of Correlation 2 */
	float max_corr_coef[15]; /* (14) Maximal Correlation Coefficient */
	} TEXTURE;


typedef struct {
/* Allows the user to choose which features to extract, a zero will cause 
   the feature to be ignored, the returned feature value will be 0.0 */
	int ASM;		/*  (1) Angular Second Moment */
	int contrast;		/*  (2) Contrast */
	int correlation;	/*  (3) Correlation */
	int variance;		/*  (4) Variance */
	int IDM;		/*  (5) Inverse Diffenence Moment */
	int sum_avg;		/*  (6) Sum Average */
	int sum_var;		/*  (7) Sum Variance */
	int sum_entropy;	/*  (8) Sum Entropy */
	int entropy;		/*  (9) Entropy */
	int diff_var;		/* (10) Difference Variance */
	int diff_entropy;	/* (11) Diffenence Entropy */
	int meas_corr1;		/* (12) Measure of Correlation 1 */
	int meas_corr2;		/* (13) Measure of Correlation 2 */
	int max_corr_coef; 	/* (14) Maximal Correlation Coefficient */
	} TEXTURE_FEATURE_MAP;

