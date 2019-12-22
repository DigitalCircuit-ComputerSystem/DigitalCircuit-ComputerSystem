#include<stdio.h>
#include <stdlib.h>

#define DEPTH 1024     /*数据深度，即存储单元的个数*/
#define WIDTH 32       /*存储单元的宽度*/

unsigned int tran(char* c){
	unsigned ret = 0;
	for(int i = 0; i < 8; i++){
		ret *= 16;
		if(*c <= '9' && *c >='0') ret += *c - '0';
		else ret += *c - 'a'+10;
		c++;
	}
	return ret;
}

int main(void)
{
    int i,temp;
    float s;
	static char read_data[9];
	read_data[8] = 0;
    FILE *fp;
    FILE *fpread = fopen("os", "r");
    fp = fopen("os.mif","w");   /*文件名随意，但扩展名必须为.mif*/
    if(NULL==fp)
        printf("Can not creat file!\r\n");
    else
    {
        printf("File created successfully!\n");
        /*
        *    生成文件头：注意不要忘了“;”
        */
        fprintf(fp,"DEPTH = %d;\n",DEPTH);
        fprintf(fp,"WIDTH = %d;\n",WIDTH);
        fprintf(fp,"ADDRESS_RADIX = HEX;\n");
        fprintf(fp,"DATA_RADIX = HEX;\n");
        fprintf(fp,"CONTENT\n");
        fprintf(fp,"BEGIN\n");

        /*
        * 以十六进制输出地址和数据
        */
        for(i=0;i<DEPTH;i++)
        {
             /*周期为128个点的正弦波*/ 
           fread(read_data, 1, 9, fpread);
            fprintf(fp,"%x\t:\t%x;\n",i,tran(read_data));
            //printf("data: %s\n, %x\n",read_data, trans(read_data));
            //system("pause");
        }//end for
  //       while(fread(read_data, 8, 1, fp)){
		// 	//fputs(read_data, fpout);
		// 	fprintf(fp,"%x\t:\t%x;\n",i,temp);
		// }
        fprintf(fp,"END;\n");
        fclose(fp);
    }
}

// int main(){
// 	FILE *fp = fopen("os", "r");
// 	FILE *fpout = fopen("os.mif", "w");
// 	static char read_data[9];
// 	read_data[8] = 0;
// 	while(fread(read_data, 8, 1, fp)){
// 		fputs(read_data, fpout);
// 	}
// 	return 0;
// }