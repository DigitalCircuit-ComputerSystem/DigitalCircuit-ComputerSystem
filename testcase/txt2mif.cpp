#include <bits/stdc++.h>
#define DEPTH 4096
#define WIDTH 32
using namespace std;

int main(){
    FILE *fp;
    fp = fopen("loadrel.mif","w");
    if(fp==NULL)
        printf("Fail to creat file!\r\n");
    else{
        printf("Create file successfully!\n");
        //Header:
        fprintf(fp,"DEPTH = %d;\n",DEPTH);
        fprintf(fp,"WIDTH = %d;\n",WIDTH);
        fprintf(fp,"ADDRESS_RADIX = HEX;\n");
        fprintf(fp,"DATA_RADIX = HEX;\n");
        fprintf(fp,"CONTENT\n");
        fprintf(fp,"BEGIN\n");

        FILE *txt;
        assert(txt = fopen("loadrel.txt", "r"));
        for(int i=0; i<DEPTH; i++){
            long long temp;
            fscanf(txt,"%llx", &temp);
            fprintf(fp,"%x\t:\t%08llx;\n",i,temp);
        }
        fprintf(fp,"END;\n");
        fclose(fp);
        fclose(txt);
    }
}