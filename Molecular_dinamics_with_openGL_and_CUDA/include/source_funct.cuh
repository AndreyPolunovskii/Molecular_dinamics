__device__  scalar r_module(vector3d ri,vector3d rj)
{
	
	scalar r_mod1 = sqrt( (ri.x - rj.x)*(ri.x - rj.x) + (ri.y - rj.y)*(ri.y - rj.y) + (ri.z - rj.z)*(ri.z - rj.z) );
	
	return r_mod1;
}
 //-----------------------------------------------------------
__device__  vector3d force(vector3d * ri,scalar sigma,scalar pow_sigma_12,scalar pow_sigma_6,scalar eps,int N1,int ix)
{ 
    scalar r_mod,inv_r_mod;
    
    scalar diff_leonard_Dgonson_potential = 0.;
  
    vector3d vect_force_i;
    
    vect_force_i.x = 0.;
    vect_force_i.y = 0.;
    vect_force_i.z = 0.;
    
   //  printf(" радиус вектор = (%.2f %.2f %.2f)\n",ri[ix].x,ri[ix].y,ri[ix].z );


   // #pragma unroll
    for ( int j = 0 ; j < N1; j++ )
        if ( j != ix) 
        {
			 r_mod = r_module(ri[ix],ri[j]);	
			 
			 inv_r_mod = 1./r_mod; 
 
			 diff_leonard_Dgonson_potential = 4.*eps*( pow_sigma_12/pow(r_mod,13.) - pow_sigma_6/pow(r_mod,7.) );
			 
			// printf("r_mod ( %d %d %.10f )\n ",ix,j,r_mod);

		  if ( r_mod < 2.5*sigma )	
		  { 

             vect_force_i.x += diff_leonard_Dgonson_potential*(ri[ix].x - ri[j].x)* inv_r_mod;
             vect_force_i.y += diff_leonard_Dgonson_potential*(ri[ix].y - ri[j].y)* inv_r_mod;
             vect_force_i.z += diff_leonard_Dgonson_potential*(ri[ix].z - ri[j].z)* inv_r_mod;

          }
	    }
	    
	
	
	return vect_force_i;
}
//--------------------------
__global__  void coordinates(vector3d * r1,vector3d * r0,vector3d * v0,vector3d * a0,scalar ht,scalar ht_ht)
{
	
	const int ix = blockDim.x * blockIdx.x + threadIdx.x;



    r1[ix].x = r0[ix].x + v0[ix].x * ht + ((scalar) 0.5 )* a0[ix].x * ht_ht;
    r1[ix].y = r0[ix].y + v0[ix].y * ht + ((scalar) 0.5 )* a0[ix].y * ht_ht;
    r1[ix].z = r0[ix].z + v0[ix].z * ht + ((scalar) 0.5 )* a0[ix].z * ht_ht;
  
  /*  
    scalar a = v0[ix].x ;
    scalar b = ((scalar) 0.5 )* a0[ix].x ;
    
    //преобразование Шенкса
    r1[ix].x = ( a* r0[ix].x + ( pow(a,2) - b* r0[ix].x ) * ht ) / ( a - b * ht )  ;
    
    a = v0[ix].y  ;
    b = ((scalar) 0.5 )*a0[ix].y  ;
    
    r1[ix].y = ( a  * r0[ix].y + ( pow(a,2) - b  * r0[ix].y ) * ht ) / ( a - b * ht );
    
    a = v0[ix].z ;
    b = ((scalar) 0.5 )*a0[ix].z ;
    
    r1[ix].z = ( a* r0[ix].z + ( pow(a,2) - b * r0[ix].z) * ht ) / ( a - b * ht )  ;*/
	
}
 //-----------------------------------------------------------

__global__  void acceleration(vector3d * ai,vector3d * ri,scalar sigma,scalar pow_sigma_12,scalar pow_sigma_6,scalar eps,scalar inv_m,int N1)
{
	const int ix = blockDim.x * blockIdx.x + threadIdx.x;
 
    //тут вычисляются ускорения
 
    
   vector3d vector_force_i;

   vector_force_i = force(ri,sigma,pow_sigma_12,pow_sigma_6,eps,N1,ix);
	
	
   ai[ix].x = vector_force_i.x * inv_m;
   ai[ix].y = vector_force_i.y * inv_m;
   ai[ix].z = vector_force_i.z * inv_m;
}
//---------------------------

__global__  void velocity(vector3d * v1,vector3d * v0,vector3d * a0,vector3d * a1,scalar ht)
{
	const int ix = blockDim.x * blockIdx.x + threadIdx.x;
 
    //тут вычисляются скорости
         
     v1[ix].x = v0[ix].x + ((scalar) 0.5 )*( a0[ix].x + a1[ix].x ) * ht;
     v1[ix].y = v0[ix].y + ((scalar) 0.5 )*( a0[ix].y + a1[ix].y ) * ht;
     v1[ix].z = v0[ix].z + ((scalar) 0.5 )*( a0[ix].z + a1[ix].z ) * ht;
      
      
    
	
}
 //-----------------------------------------------------------


