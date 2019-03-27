#ifndef PARAMETERS_H_INCLUDED
#define PARAMETERS_H_INCLUDED

typedef double scalar;

namespace parameters_solver {

#define Pi (scalar) 3.1415926535897932384626433832795028841971


#define Nx 10 // ребро частиц (N^(1/3))

#define N Nx*Nx*Nx // количество цастиц 

//125000 частиц - 20 сек расчета на моем девайсе ( GeForce 1080 Ti ) на одном шаге

#define BLOCK_SIZE 100 // размерность блока на cuda

//сейчас пока скорость начальная нулевой задается
#define MAX_V 1e+1 // максимальная компонента скорости частицы в начале 
#define DEV_V 1e+5

scalar L = 400.f; // длина ребра куба, в котором наши частицы

const int initcond = 1 ;//тип граничных условий

//1 - отражающие граничные условия (стенки)
//2 - периодические граничные условия


scalar alfa = 0.05;//0.05; // параметр сжатия расположения частиц в начале расчета

//относительный радиус частицы
scalar r = 0.00001*L;

// шаг по времени
scalar ht =2e-1;//2e-3;//5e-4;//0.00001;

//можно потом ввести адаптивный шаг

//стенки вводят неустойчивости в расчет

int col_steps =  60000; // количество шагов по времени


//параметры модели
//
//---------------------
//Неон
scalar eps = 0.003;//0.003; //eV
scalar sigma = 2.74;//ангстрем  (м*10^(-10)) 
scalar m = 0.033;//кг *10^(-24)      //3.3*1e-26; //кг

scalar k_b = eps/36.2;// 1.38064852 *1e-23; //Dj * K^-1

//---------------------

//Дж = кг*м^2/c^2
//эВ = 1.6 *10^(-19) Дж

scalar inv_m = 1/m;


struct vector3d {
	 scalar x;
	 scalar y;
	 scalar z;
 };


}

using namespace parameters_solver;

// файл для записи координат

std::string file_str1("output_data_point.txt");

std::fstream outdata; 

#endif // PARAMETERS_H_INCLUDED
