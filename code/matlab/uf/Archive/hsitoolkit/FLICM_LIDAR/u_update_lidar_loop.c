
#include "mex.h"
#include "matrix.h"
#include "blas.h"
#include "string.h"

// 
// u_update_lidar_loop.c
//  -computes the main computation loop of u_update_lidar for flicm lidar
//

typedef unsigned char uint8;

void u_update_lidar_loop(mxArray* Gc, uint8* ok, mxArray* lidar, mwSize center, mwSize n_row, mwSize n_col, mwSize n_comp, double* out);


void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]){

	mxArray* Gc;
	uint8* ok;
	mxArray* lidar;
	double* centers;
	mwSize center;
	mwSize dims[3];
	mwSize n_row, n_col, n_comp;
	double* out;

	if(nrhs != 4){
		mexErrMsgIdAndTxt("tcg:u_update_lidar_loop","The number of the inputs shall be FOUR!");
	}

	if(nlhs != 1){
		mexErrMsgIdAndTxt("tcg:u_update_lidar_loop","The number of the outputs shall be ONE!");		
	}

	Gc = prhs[0];
	ok = mxGetData(prhs[1]);
	lidar = prhs[2];
	centers = mxGetPr(prhs[3]);

	center = (mwSize)centers[0];

	n_row = mxGetM(prhs[1]);
	n_col = mxGetN(prhs[1]);
	n_comp = mxGetNumberOfElements(prhs[0]);

	dims[0] = n_comp;
	dims[1] = n_row;
	dims[2] = n_col;

	plhs[0] = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
	out = mxGetPr(plhs[0]);

	u_update_lidar_loop(Gc,ok,lidar,center,n_row,n_col,n_comp,out);

}

// for k = 1:n_col       
//     for j = 1:n_row    
//         if(ok(j,k)) %~isempty(LidarDist{j,k})
//             for i = 1:C
//                 subI = G2(j+rg, k+rg, i);
//                 G(i,j,k) = sum(sum(subI.*LidarDist{j,k}));
//  ...

void u_update_lidar_loop(mxArray* Gc, uint8* ok, mxArray* lidar, mwSize center, mwSize n_row, mwSize n_col, mwSize n_comp, double* out){

	mwSize i,j,k;
	mwSize k_off,j_off,ld_off;
	mwSize row,col;
	mwSize col_off, g_col_off;
	mwSize nr,nc;
	mxArray* ld_mat;
	double* ld;
	mxArray* G_mat;
	double* G;
	mwSize out_ind, g_base;

	for(k=0, k_off = 0, ld_off = 0; k < n_col; k++, k_off += (n_row*n_comp), ld_off += n_row){
		for(j=0, j_off = 0; j < n_row; j++, j_off += n_comp){
			if(ok[ld_off+j]){

				ld_mat = mxGetCell(lidar,ld_off+j);
				ld = mxGetPr(ld_mat); //lidar distance
				nr = mxGetM(ld_mat);
				nc = mxGetN(ld_mat);

				for(i=0; i < n_comp; i++){
					G_mat = mxGetCell(Gc,i);
					G = mxGetPr(G_mat);

					out_ind = k_off+j_off+i;
					g_base = (k-center)*n_row + j-center;
					//mexPrintf("i: %d j: %d k: %d center: %d g_base: %d out_ind: %d\n",i,j,k,center,g_base,out_ind);

					for(col = 0, col_off = 0, g_col_off = 0; col < nc; col++, col_off+=nr, g_col_off += n_row){
						for(row = 0; row < nr; row++){

							//mexPrintf("col: %d row: %d col_off: %d g_coll_off: %d ld: %f G: %f\n",col,row,col_off,g_col_off,
							//	ld[col_off + row],G[g_base + g_col_off + row]);

							out[out_ind] += ld[col_off + row]*G[g_base + g_col_off + row];
						}
					}
				}
			}

		}
	}

}
