#ifndef VARS_H_INCLUDED
#define VARS_H_INCLUDED

// обьявляем глобальные переменные

scalar T;

clock_t time2, time1;
int deviceCount;

scalar pow_sigma_12;
scalar pow_sigma_6;
scalar ht_ht;

ssize_t size;

//------------------------------------------массивы расчетных значений---------------
vector3d * dev_r1, * dev_v1, * dev_a1, * dev_r0, * dev_v0, * dev_a0; 
vector3d * r1, * v1, * a1, * r0, * v0, * a0;

         
bool flag;



#endif //VARS_H_INCLUDED
