#include "dvbs2_rx.h"

const int vl_snr_tab[16][56] = {
	{ 1,1,1,1, 1,0,1,1, 1,1,1,1, 0,0,1,0, 0,0,1,1, 1,1,1,0, 1,0,0,0, 0,0,1,1, 0,1,1,1, 1,1,1,1, 1,0,0,1, 1,0,1,1, 1,1,0,0, 0,1,0,0 },
	{1,0,0,1, 1,0,0,0, 0,1,1,1, 0,0,0,0, 1,0,0,0, 1,1,1,0, 0,0,0,0, 1,0,1,1, 0,0,1,1, 1,0,0,1, 0,0,1,1, 0,1,0,0, 0,1,0,1, 1,1,1,0},
	{1,1,1,1, 0,1,1,0, 1,0,1,0, 0,0,1,0, 1,1,0,0, 1,0,0,1, 1,1,1,1, 1,1,1,0, 0,0,0,1, 1,0,1,1, 0,0,0,1, 0,1,1,1, 0,0,1,1, 0,1,1,1},
	{1,0,0,0, 0,1,0,0, 0,0,0,1, 1,0,0,0, 1,1,0,1, 1,0,0,1, 0,1,0,1, 1,0,1,0, 0,1,1,0, 1,1,1,1, 1,0,0,1, 1,0,0,1, 0,1,1,1, 1,0,1,0},
	{0,1,1,1, 1,0,1,1, 0,1,1,1, 1,1,0,1, 0,1,1,1, 1,0,1,1, 0,0,1,1, 1,1,1,0, 1,0,0,1, 1,1,1,1, 1,1,0,0, 1,0,0,1, 1,1,1,0, 1,0,1,0},
	{0,1,0,1, 1,1,1,0, 0,1,1,1, 1,0,0,0, 1,0,1,1, 1,0,1,0, 0,0,0,0, 0,0,1,1, 1,0,1,0, 0,1,1,0, 1,1,0,1, 0,1,0,1, 0,0,0,1, 1,0,1,0},
	{0,0,1,0, 0,1,1,1, 1,0,0,1, 1,1,0,0, 1,1,0,0, 0,0,1,0, 0,1,1,0, 0,1,0,1, 0,1,0,0, 0,0,1,1, 1,1,1,0, 1,1,0,0, 1,1,0,1, 0,0,0,0},
	{0,0,1,1, 0,1,0,0, 0,0,1,0, 1,0,1,1, 0,0,0,0, 0,1,0,0, 1,0,0,1, 1,0,0,0, 1,0,1,1, 1,1,1,1, 0,0,1,1, 1,1,0,1, 0,1,1,1, 1,1,0,1},
	{1,0,1,0, 1,1,0,1, 1,1,0,1, 0,0,0,0, 0,0,1,1, 0,1,1,0, 1,1,1,0, 1,0,0,1, 1,1,0,1, 0,1,0,1, 0,0,1,1, 0,0,0,1, 0,0,1,0, 1,1,1,1},
	{0,0,0,1, 0,0,0,0, 0,1,1,0, 0,0,0,1, 1,1,0,0, 0,1,1,0, 1,1,0,1, 1,1,1,1, 1,0,0,0, 0,0,1,0, 0,1,1,0, 0,0,1,0, 0,0,1,1, 0,1,1,1},
	{0,1,1,1, 0,0,1,0, 1,1,0,1, 0,0,1,1, 1,1,1,0, 0,0,0,0, 1,0,0,1, 0,0,0,0, 0,1,1,1, 0,0,1,1, 1,0,0,0, 0,1,0,0, 1,1,0,0, 0,1,1,1},
	{0,0,1,1, 1,0,1,1, 1,1,0,1, 0,1,0,1, 1,0,1,0, 1,1,0,0, 1,1,1,0, 1,1,1,0, 0,0,1,0, 0,1,0,1, 1,1,1,0, 0,0,1,0, 1,1,0,0, 1,0,0,1},
	{0,1,0,1, 1,0,0,1, 0,0,0,0, 1,0,0,0, 0,1,1,1, 1,1,0,1, 1,0,0,0, 0,0,1,0, 0,1,1,0, 0,0,0,1, 0,1,0,1, 1,0,1,0, 1,1,0,1, 1,0,1,0},
	{1,1,1,0, 1,0,0,1, 1,0,1,0, 1,1,1,1, 0,0,0,0, 0,0,0,1, 0,1,1,1, 0,0,1,0, 1,1,0,0, 1,1,1,1, 1,0,0,1, 1,1,0,1, 1,0,1,0, 0,1,1,1},
	{0,0,1,1, 1,1,1,1, 0,1,0,0, 1,0,0,0, 0,0,1,1, 0,1,0,1, 1,0,1,0, 0,1,0,0, 0,0,0,0, 0,1,1,0, 0,0,1,1, 1,1,1,1, 0,0,0,0, 0,1,1,1},
	{0,0,1,0, 0,0,1,1, 1,1,0,0, 1,0,0,1, 1,0,1,0, 1,1,1,0, 1,1,1,0, 1,1,0,0, 1,1,1,1, 0,0,1,0, 1,1,1,0, 1,1,0,1, 0,1,0,0, 0,0,0,1}
};

const int wh_seq[16][16] = {
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0 },
	{ 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0 },
	{ 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1 },
	{ 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0 },
	{ 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0 },
	{ 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1 },
	{ 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0 },
	{ 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 },
	{ 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1 },
	{ 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1 },
	{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1 },
	{ 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0 },
	{ 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0 },
	{ 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1 }
};

FComplex vl_snr_preamble[900];

extern FComplex m_bpsk0[2][2];// located in pl_decode module
extern FComplex m_bpsk1[2][2];// located in pl_decode module

void vl_snr_build_header(int n){
	int a[900];
	int index = 0;
	a[index++] = 0;
	a[index++] = 0;

	for (int i = 0; i < 16; i++){
		if (wh_seq[n][i]){
			for (int j = 0; j < 16; j++){
				a[index++] = vl_snr_tab[i][j];
			}
		}
		else{
			for (int j = 0; j < 16; j++){
				a[index++] = vl_snr_tab[i][j]^1;
			}
		}
	}
	a[index++] = 0;
	a[index++] = 0;

	// Now apply the pi/2 BPSK
	for (int i = 0; i < 900; i++){
		vl_snr_preamble[i] = m_bpsk0[i&1][a[i]];
	}
}