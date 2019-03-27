

template<class T2>
T2 find_max(T2 * SX)
{
    T2 max = 0;
    for (size_t j = 0; j < N - 1; j ++)
            if (abs(max) < abs(SX[j]))
                    max = abs(SX[j]);
                    
    return max;
}
//--------------------------------------------
scalar inifunct(size_t &la)
{

  switch (initcond)
   {
    // 2*A*(-cos(pi*la/4)+cos(3*pi*la/4))/(pi*la)
    case 1 : return (scalar) ( sin( 2* Pi*((int)la)/(int)(N - 1) ) );

    case 2 : return  2;

    case 3 : return  ((int)la == 1) ? 3 : 0 ;
   }
   
   return 0;
}
//---------------------------------------------
scalar find_temperature(vector3d * v0,int N1,scalar m)
{
    scalar v_quad = 0.,v_quad_integral = 0., E_average,T;
    for (int j = 0; j < N1; j ++)
    {
            v_quad = pow(v0[j].x,2.) + pow(v0[j].y,2.) + pow(v0[j].z,2.);
            v_quad_integral += v_quad;
    }
     
   
    E_average =  m*v_quad_integral/(2.*N1);

    
    T = ((scalar)E_average /(scalar)k_b) *((scalar)2./3.);
    
            
    return T;
}
//--------------------------------------------

//---------------------------------------------
scalar find_pressure(vector3d * v0,int N1,scalar m)
{
	
	scalar T = find_temperature(v0,N1,m);
	
    scalar p = (N1/pow(L,3.)) * k_b * T;
            
    return p;
}
//--------------------------------------------


