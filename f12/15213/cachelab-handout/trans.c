/* 
 * trans.c - Matrix transpose B = A^T
 *
 * Each transpose function must have a prototype of the form:
 * void trans(int M, int N, int A[N][M], int B[M][N]);
 *
 * A transpose function is evaluated by counting the number of misses
 * on a 1KB direct mapped cache with a block size of 32 bytes.
 */ 
#include <stdio.h>
#include "cachelab.h"
#include "contracts.h"

int is_transpose(int M, int N, int A[N][M], int B[M][N]);

/* 
 * transpose_submit - This is the solution transpose function that you
 *     will be graded on for Part B of the assignment. Do not change
 *     the description string "Transpose submission", as the driver
 *     searches for that string to identify the transpose function to
 *     be graded. The REQUIRES and ENSURES from 15-122 are included
 *     for your convenience. They can be removed if you like.
 */
char transpose_submit_desc[] = "Transpose submission";
void transpose_submit(int M, int N, int A[N][M], int B[M][N])
{
    int i, j, k, numblocks, tmp, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8;
    numblocks = M/8;
    if (numblocks * 8 < M) numblocks += 1;

    if (N != 64) // this optimization works well when N != 64
        // blocks into 8 bytes and separates/sorts reads and writes
        for (k = 0; k < numblocks; k++)
            for (i = 0; i < N; i++) {
                j = 8*k;
                tmp = A[i][j];
                if(j+1 < M)
                    tmp2 = A[i][j+1];
                if(j+2 < M)
                    tmp3 = A[i][j+2];
                if(j+3 < M)
                    tmp4 = A[i][j+3];
                if(j+4 < M)
                    tmp5 = A[i][j+4];
                if(j+5 < M)
                    tmp6 = A[i][j+5];
                if(j+6 < M)
                    tmp7 = A[i][j+6];
                if(j+7 < M)
                    tmp8 = A[i][j+7];
                B[j][i] = tmp;
                if(j+1 < M)
                    B[j+1][i] = tmp2;
                if(j+2 < M)
                    B[j+2][i] = tmp3;
                if(j+3 < M)
                    B[j+3][i] = tmp4;
                if(j+4 < M)
                    B[j+4][i] = tmp5;
                if(j+5 < M)
                    B[j+5][i] = tmp6;
                if(j+6 < M)
                    B[j+6][i] = tmp7;
                if(j+7 < M)
                    B[j+7][i] = tmp8;
            }    
    else
      // for 64 height, do a down/right/up/right repeat 4 byte blocking
      for (k = 0; k < M/4; k++)
        for (j = 0; j < N; j++)
          if (j % 2 == 0)
          {
              tmp = A[4*k][j];
              if(4*k+1 < M)
                  tmp2 = A[4*k+1][j];
              if(4*k+2 < M)
                  tmp3 = A[4*k+2][j];
              if(4*k+3 < M)
                  tmp4 = A[4*k+3][j];
              if(4*k+3 < M)
                  B[j][4*k+3] = tmp4;
              if(4*k+2 < M)
                  B[j][4*k+2] = tmp3;
              if(4*k+1 < M)
                  B[j][4*k+1] = tmp2;
              B[j][4*k] = tmp;
          }
          else
          {
              if(4*k+3 < M)
                  tmp4 = A[4*k+3][j];
              if(4*k+2 < M)
                  tmp3 = A[4*k+2][j];
              if(4*k+1 < M)
                  tmp2 = A[4*k+1][j];
              tmp = A[4*k][j];
              B[j][4*k] = tmp;
              if(4*k+1 < M)
                  B[j][4*k+1] = tmp2;
              if(4*k+2 < M)
                  B[j][4*k+2] = tmp3;
              if(4*k+3 < M)
                  B[j][4*k+3] = tmp4;
          }
}

/* 
 * You can define additional transpose functions below. We've defined
 * a simple one below to help you get started. 
 */ 

/* 
 * trans - A simple baseline transpose function, not optimized for the cache.
 */
char trans_desc[] = "Simple row-wise scan transpose";
void trans(int M, int N, int A[N][M], int B[M][N])
{
    int i, j, tmp;

    REQUIRES(M > 0);
    REQUIRES(N > 0);

    for (i = 0; i < N; i++) {
        for (j = 0; j < M; j++) {
            tmp = A[i][j];
            B[j][i] = tmp;
        }
    }    

    ENSURES(is_transpose(M, N, A, B));
}

/*
 * registerFunctions - This function registers your transpose
 *     functions with the driver.  At runtime, the driver will
 *     evaluate each of the registered functions and summarize their
 *     performance. This is a handy way to experiment with different
 *     transpose strategies.
 */
void registerFunctions()
{
	/* Register your solution function */
    registerTransFunction(transpose_submit, transpose_submit_desc); 

    /* Register any additional transpose functions */
    registerTransFunction(trans, trans_desc); 

}

/* 
 * is_transpose - This helper function checks if B is the transpose of
 *     A. You can check the correctness of your transpose by calling
 *     it before returning from the transpose function.
 */
int is_transpose(int M, int N, int A[N][M], int B[M][N])
{
    int i, j;

    for (i = 0; i < N; i++) {
        for (j = 0; j < M; ++j) {
			if (A[i][j] != B[j][i]) {
				return 0;
			}
		}
    }
    return 1;
}

