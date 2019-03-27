#include "include_files.h"
#include "parameters.h"
#include "vars.h"

#include "solver_file.h"
#include "source_funct.cuh"
#include "add_functions.h"

//---------------------------------------------------
int init_function(void)
{
	T = col_steps * ht;
	
	time1 = clock();
	
	std::cout << " Длина отрезка интегрирования по времени = " << col_steps * ht << std::endl;

      
    //Сколько устройств CUDA установлено на PC.
    cudaGetDeviceCount(&deviceCount);
    printf("Device count: %d\n\n", deviceCount);


    pow_sigma_12 = 12.f*pow(sigma,12);
	pow_sigma_6 = 6.f*pow(sigma,6);
	ht_ht = ht*ht;

    // размер массива из N 3dвекторов
	size = N * sizeof(vector3d);

    // выделяем память на видюхе
	cudaMalloc( (void**)&dev_r0, size );
	cudaMalloc( (void**)&dev_v0, size );
	cudaMalloc( (void**)&dev_a0, size );
	        
	 cudaMalloc( (void**)&dev_r1, size );
	 cudaMalloc( (void**)&dev_v1, size );
	 cudaMalloc( (void**)&dev_a1, size );

	       
	 // выделяем память в оперативке 	        
	 r0 = (vector3d*) malloc( size );
	 v0 = (vector3d*) malloc( size );
	 a0 = (vector3d*) malloc( size );
	        
	 r1 = (vector3d*) malloc( size );
	 v1 = (vector3d*) malloc( size );
	 a1 = (vector3d*) malloc( size );
	        
	       // задаем н. у.
	       // нельзя задавать частицы друг в друге!!!

				 // задаем вдоль линии x частицы
               /*  r0[l].y =  (1./2. - alfa )* L + ( ((scalar) l)/((scalar)N))*( 2*alfa )*L;//l*hx;
                 r0[l].x =  ((scalar) ((1./2. - alfa )*L+ rand() % (int)(2*alfa*L) ));//l*hx+1;
                 r0[l].z =  (1./2. - alfa )* L + ( ((scalar) l)/((scalar)N))*( 2*alfa )*L;//l*hx+2;*/
               
                for (int i=0 ; i < Nx; ++i)
                 for (int j=0 ; j < Nx; ++j)
                  for (int k=0 ; k < Nx; ++k)
	          {  
                 int iter = i + j*Nx + k *Nx*Nx;       
                 r0[iter].y =  (1./2.-alfa)*L + ( (scalar) i)/((scalar) Nx )*(2.*alfa*L);
                 r0[iter].x =  (1./2.-alfa)*L + ( (scalar) j)/((scalar) Nx )*(2.*alfa*L);
                 r0[iter].z =  (1./2.-alfa)*L + ( (scalar) k)/((scalar) Nx )*(2.*alfa*L);
               }  
          
                
              for (int l=0 ; l < N; ++l)
	        { 
                 v0[l].x = 0;// (scalar) (-MAX_V + rand() % (int)2*MAX_V)/((scalar)DEV_V);
                 v0[l].y = 0;// (scalar) (-MAX_V + rand() % (int)2*MAX_V)/((scalar)DEV_V);
                 v0[l].z = 0;// (scalar) (-MAX_V + rand() % (int)2*MAX_V)/((scalar)DEV_V);
                 
                 
             }
             
        /*     	        for (ssize_t l=0 ; l < N; ++l)
	        {
				std::cout << r0[l].x << std::endl;
                std::cout << r0[l].y << std::endl;
                std::cout << r0[l].z << std::endl;
			} */
       
        // задаем размерности сетки на видеокарте         
        dim3 threads ( BLOCK_SIZE );
        dim3 blocks  ( N / threads.x);
       
       // копируем содержимое переменных из оперативы в переменные на девайсе      
       cudaMemcpy(dev_r0 , r0, size, cudaMemcpyHostToDevice );
       
       acceleration<<< blocks , threads >>>(dev_a0,dev_r0,sigma,pow_sigma_12,pow_sigma_6,eps,inv_m,(int)N);
    
       cudaMemcpy(a0 , dev_a0, size, cudaMemcpyDeviceToHost );
   
     flag = 0;
    
     outdata.open(file_str1);
    
     return 0;
	        
}

//--------------------------------------------------

int main_solver(int k) {

           // задаем размерности сетки на видеокарте         
           dim3 threads ( BLOCK_SIZE );
           dim3 blocks  ( N / threads.x);
            	       
           // запускаем цикл по времени  
         //---------------------------------------------------------
		   time2 = clock();
		   
		     // create cuda event handles
            cudaEvent_t start, stop;
            float gpuTime = 0.0f;
            cudaEventCreate ( &start );
            cudaEventCreate ( &stop );
            
             // asynchronously issue work to the GPU (all to stream 0)
            cudaEventRecord ( start, 0 );
		   
	       // копируем содержимое переменных из оперативы в переменные на девайсе      
	       cudaMemcpy(dev_r0 , r0, size, cudaMemcpyHostToDevice );
	       cudaMemcpy(dev_v0 , v0, size, cudaMemcpyHostToDevice );
	       cudaMemcpy(dev_a0 , a0, size, cudaMemcpyHostToDevice );
	        	    
	       // алгоритм Верле    
	       coordinates<<< blocks , threads >>>(dev_r1,dev_r0,dev_v0,dev_a0,ht,ht_ht);
	       acceleration<<< blocks , threads >>>(dev_a1,dev_r1,sigma,pow_sigma_12,pow_sigma_6,eps,inv_m,(int)N);
	       velocity<<< blocks , threads >>>(dev_v1,dev_v0,dev_a0,dev_a1,ht);

	        // Обратно копируем       
	       cudaMemcpy(r1 , dev_r1, size, cudaMemcpyDeviceToHost );
	       cudaMemcpy(v1 , dev_v1, size, cudaMemcpyDeviceToHost );
	       cudaMemcpy(a1 , dev_a1, size, cudaMemcpyDeviceToHost );
	       
	       //определяем точку завершения работы видеокарты
	       cudaEventRecord ( stop, 0 );
           cudaEventSynchronize ( stop );
           cudaEventElapsedTime ( &gpuTime, start, stop );
	       
	       #pragma parallel for
	       for (ssize_t i=0 ; i < N; ++i)
	       {
                 r0[i].x = r1[i].x ;
                 r0[i].y = r1[i].y ;
                 r0[i].z = r1[i].z ;
                 
                 
                 
                 v0[i].x = v1[i].x ;
                 v0[i].y = v1[i].y ;
                 v0[i].z = v1[i].z ;
                 
    
                 
                 a0[i].x = a1[i].x ;
                 a0[i].y = a1[i].y ;
                 a0[i].z = a1[i].z ;

                 if (initcond == 1) // отражающие граничные условия
                {
					
                 if ( r0[i].x < 0)
                 {
                       r0[i].x = -r0[i].x;
                       v0[i].x = -v0[i].x;
                       a0[i].x = -a0[i].x;
                 }
                  
                 if ( r0[i].y < 0)
                 {
                       r0[i].y = -r0[i].y;
                       v0[i].y = -v0[i].y;
                       a0[i].y = -a0[i].y; 
                 }
                       
                 if ( r0[i].z < 0)
                 {
                       r0[i].z = -r0[i].z;
                       v0[i].z = -v0[i].z;
                       a0[i].z = -a0[i].z;
                 }
                       
                 if ( r0[i].x > L)
                 {
                       r0[i].x = 2*L - r0[i].x ;
                       v0[i].x =  - v0[i].x ;
                       a0[i].x =  - a0[i].x ;
                 }
                  
                 if ( r0[i].y > L)
                 {
                       r0[i].y = 2*L - r0[i].y ;
                       v0[i].y = - v0[i].y ;
                       a0[i].y = - a0[i].y ; 
				 }
                       
                 if ( r0[i].z > L)
                 {
                      r0[i].z = 2*L - r0[i].z ;
                      v0[i].z = - v0[i].z ;
                      a0[i].z = - a0[i].z ;
                 }
                 
                }
                else if (initcond == 2) // периодические граничные условия
                {
					
                 if ( r0[i].x < 0)
                       r0[i].x = L+r0[i].x;
            
                  
                 if ( r0[i].y < 0)
                       r0[i].y = L+r0[i].y;

                       
                 if ( r0[i].z < 0)
                       r0[i].z = L+r0[i].z;

                       
                 if ( r0[i].x > L)
                       r0[i].x =  r0[i].x - L ;

                  
                 if ( r0[i].y > L)
                       r0[i].y =  r0[i].y - L ;
                       
                 if ( r0[i].z > L)
                      r0[i].z =  r0[i].z - L ;
                 
                }

	       }
	       
	       


           
	                          
	       // сохраняем координаты в файл
           outdata << k*ht<<" ";
           for (int j=0 ; j < N; ++j)
           {
               outdata <<  r0[j].x << " " ;
               outdata <<  r0[j].y << " " ;
               outdata <<  r0[j].z << " " ;
            }
            
            outdata << std::endl; 
           
           #pragma parallel for
           for (int j=0 ; j < N; ++j)
           {
             // соответственно рисуем частички
               glPushMatrix();
               glTranslatef( (r0[j].x-L/2)*2/L, (r0[j].y-L/2)*2/L, (r0[j].z-L/2)*2/L );
               glColor3f(0.82, 0.25, 0.078);
               glutSolidSphere(r, 20, 10);
               glPopMatrix();   
           }




              time1 = clock() - time1;
              time2 = clock() - time2;
             
             if (k % 100 == 0)
            { 
			  printf("time spent executing by the GPU: %.2f millseconds\n", gpuTime );
		      std::cout << k <<"-ый шаг интегрирования" << std::endl;
              std::cout <<"x координата " << (int)N/2 <<"-ой частицы: "<< r0[(int)N/2].x << " в " << k*ht <<"-ую расчетную секунду" << std::endl;
              std::cout <<"скорость " << (int)N/2 <<"-ой частицы: "<< sqrt( pow(v0[(int)N/2].x,2) + pow(v0[(int)N/2].y,2) + pow(v0[(int)N/2].z,2) ) << " в " << k*ht <<"-ую расчетную секунду" << std::endl;
              std::cout <<"средняя температура : " << find_temperature(v0,(int)N,m) << std::endl;
              std::cout <<"среднее давление : " << find_pressure(v0,(int)N,m) << std::endl;
              std::cout << "проинтегрирован отрезок = " << k*ht << std::endl;
              std::cout << "выполнено :" << k*ht*100/T <<"%" << std::endl;

              std::cout << "время, потраченное на одну итерацию :" << ((double) time2)/CLOCKS_PER_SEC << " секунд(ы)" << std::endl;
              std::cout << "общее прошедшее время : " << ((double) time1)/CLOCKS_PER_SEC << " секунд(ы)" << std::endl;
    
              std::cout << "----------------------------" << std::endl;
              std::cout << std::endl;
            }
            
            
	        	                   
            return 0;
}
  
//---------------------------------------------------
int free_function(void)
{
	// освобождаем память
    free( r0 );
    free( v0 );
    free( a0 );
	        
    free( r1 );
    free( v1 );
    free( a1 );
	        
    cudaFree( dev_r0 );
    cudaFree( dev_v0 );
    cudaFree( dev_a0 );
	         
    cudaFree( dev_r1 );
    cudaFree( dev_v1 );
    cudaFree( dev_a1 );
    
    outdata.close();
    
    return 0;
	        
}
