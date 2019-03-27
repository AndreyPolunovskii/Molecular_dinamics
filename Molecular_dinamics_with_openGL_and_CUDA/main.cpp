#include "include_files.h"
#include "parameters.h"
#include "solver_file.h"



int k = 1;// итератор по времени

// view params
int ox, oy;
int buttonState = 0;
float camera_trans[] = {0, 0, -3};
float camera_rot[]   = {0, 0, 0};
float camera_trans_lag[] = {0, 0, -3};
float camera_rot_lag[] = {0, 0, 0};
const float inertia = 0.1f;

const uint width = 640, height = 480;

bool displaySliders = false;
bool demoMode = false;
int idleCounter = 0;
int demoCounter = 0;



// initialize OpenGL
void initGL(int *argc, char **argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_RGB | GLUT_DEPTH | GLUT_DOUBLE);
    glutInitWindowSize(width, height);
    glutCreateWindow("OpenGL molecular move");

    glEnable(GL_DEPTH_TEST);
    glClearColor(0.25, 0.25, 0.25, 1.0);

    glutReportErrors();
}
//--------------------------------------------------------------------
void reshape(int w, int h)
{ 
	    if (w == 0 || h == 0) return;
	                 
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        gluPerspective(60.0, (float) w / (float) h, 0.1, 100.0);

        glMatrixMode(GL_MODELVIEW);
         
        glViewport(0, 0, w, h);  // Использование всего окна для rendering
        
}

//--------------------------------------------------
void display()
{
	
	   // render
       glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	   glMatrixMode(GL_MODELVIEW);     // очистить буфер рисования. 
	   glLoadIdentity();
	    
	      for (int c = 0; c < 3; ++c)
       {
          camera_trans_lag[c] += (camera_trans[c] - camera_trans_lag[c]) * inertia;
          camera_rot_lag[c] += (camera_rot[c] - camera_rot_lag[c]) * inertia;
       }
	      
	   glTranslatef(camera_trans_lag[0], camera_trans_lag[1], camera_trans_lag[2]);
       glRotatef(camera_rot_lag[0], 1.0, 0.0, 0.0);
       glRotatef(camera_rot_lag[1], 0.0, 1.0, 0.0);
	    
	    
	   // cube
       glColor3f(1.0, 1.0, 1.0);
       glutWireCube(2.0);
       

       glEnable(GL_POINT_SPRITE_ARB);
       glTexEnvi(GL_POINT_SPRITE_ARB, GL_COORD_REPLACE_ARB, GL_TRUE);
       glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
       glDepthMask(GL_TRUE);
       glEnable(GL_DEPTH_TEST);       
  
       main_solver(k); // тут основной решатель
	   k++;
	   
       glutSwapBuffers();
       glutReportErrors();
	    
}
//-----------------------------------------
void mouse(int button, int state, int x, int y)
{
    int mods;

    if (state == GLUT_DOWN)
    {
        buttonState |= 1<<button;
    }
    else if (state == GLUT_UP)
    {
        buttonState = 0;
    }

    mods = glutGetModifiers();

    if (mods & GLUT_ACTIVE_SHIFT)
    {
        buttonState = 2;
    }
    else if (mods & GLUT_ACTIVE_CTRL)
    {
        buttonState = 3;
    }

    ox = x;
    oy = y;

    demoMode = false;
    idleCounter = 0;


    glutPostRedisplay();
}
//-----------------------------------------
void motion(int x, int y)
{
    float dx, dy;
    dx = (float)(x - ox);
    dy = (float)(y - oy);

            if (buttonState == 3)
            {
                // left+middle = zoom
                camera_trans[2] += (dy / 100.0f) * 0.5f * fabs(camera_trans[2]);
            }
            else if (buttonState & 2)
            {
                // middle = translate
                camera_trans[0] += dx / 100.0f;
                camera_trans[1] -= dy / 100.0f;
            }
            else if (buttonState & 1)
            {
                // left = rotate
                camera_rot[0] += dy / 5.0f;
                camera_rot[1] += dx / 5.0f;
            }


    ox = x;
    oy = y;

    demoMode = false;
    idleCounter = 0;

    glutPostRedisplay();
}
//-----------------------------------------
void timer(int = 0)
{
	display();
	glutTimerFunc(10,timer,0);
}

//--------------------------------------------------
int main(int argc, char ** argv) {
	


std::string str_buf1 = "cp /dev/null "+ file_str1;

system( str_buf1.c_str() );//чистим файл перед прочитыванием

initGL(&argc, argv);


init_function();// инициализируем переменные для расчета

glutDisplayFunc(display);
glutReshapeFunc(reshape);
glutMouseFunc(mouse);
glutMotionFunc(motion);

if ( k < col_steps )
    timer();

glutMainLoop();


//if ( !system("./plot_command.gnu ") )
  //   std::cout << "в этой папке создан файлы с графиками X.eps , animate.gif и graph_moment.gif" <<std::endl;



free_function();// освобождаем память выделенную под массивы с расч. данными


return 0;

}
