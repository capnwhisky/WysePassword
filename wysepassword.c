// Basic C code to decrypt Wyse password for decoding
// Reverse engineering and C mangulation by David Lodge
// 
// Extended to include an encoder by Ryan Maloney

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void NFuseDecode(char *src, int length, unsigned char *dst)
{
   unsigned char a;
   int i;

   length/=2;

   for (i=0; i<length; i++)
   {
      a=src[i*2];
      a-=1;
      a<<=4;
      a+=src[i*2+1];
      a-=0x41;
      dst[i]=a;
   }

   for (i=length; i>=0; i--)
   {
      a=dst[i-1];
      a^=dst[i];
      a^=0xA5;
      dst[i]=a;
   }
   dst[length]='\0';
}

void NFuseEncode(char *src, int length, unsigned char *dst)
{
  unsigned char a,b,temp[256];
  int i,y;

  for (i=0; i<length; i++)
  {
    a=src[i];
    a^=0xA5;
    a^=temp[i-1];
    temp[i]=a;
    y=i*2;
    b=a;
    b=b & 0x0F;
    b+=0x41;
    a>>=4;
    a+=0x41; 
    dst[y]=a;
    dst[y+1]=b;
  }
   dst[length*2]='\0';
}


int main(int argc, char **argv)
{
   unsigned char buffer[256];
   int opt;
   
   if (argc < 2) {
	   printf("Usage: %s [OPTION] PASSWORD\nExample: %s -e somepassword\
			   \nOptions:\n -d\t\tEncode password\n -e\t\tDecode Password\n\n", argv[0],argv[0]);
	   return -1;
   }
  
   while ((opt = getopt(argc, argv, "e:d:")) != -1) {
	switch(opt) {
		case 'e':
   			NFuseEncode(optarg,strlen(optarg), buffer);
   			printf("%s\n", buffer);
			break;
		case 'd':
			NFuseDecode(optarg,strlen(optarg), buffer);
   			printf("%s\n", buffer);
			break;
		case ':':
			printf("Option needs a value\n");
			break;
	}
   }
   return 0;
}
