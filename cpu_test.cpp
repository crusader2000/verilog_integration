#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
// change len, lenr and input values according to you need

using namespace std;
#define chunk 1

void allwrite(int fd, unsigned char *buf, int leng);
void allread(int fd, unsigned char *buf, int leng);

int main()
{
    int fdr, fdw;
    fdr = open("/dev/xillybus_read_32", O_RDONLY);
    if (fdr < 0) {
        perror("Failed to open read Xillybus device");
        exit(1);
    }
    fdw = open("/dev/xillybus_write_32", O_WRONLY);
    if (fdw < 0) {
        perror("Failed to open write Xillybus device");
        exit(1);
    }
    unsigned char *buf=(unsigned char *)malloc(4000000 * sizeof(unsigned char*));
    unsigned char *input=(unsigned char *)malloc(4000000 * sizeof(unsigned char*));
    long double t1;
    int fcount = 0;
// here: input of your processor
// since input is 4 bytes and input's one block is one byte therefore for one instruction 4 blocks of input are utilised
// here example for 6 instructions
    for(int i=0;i<24; i=i+4){
  	input[i] =(unsigned char)i;
  	input[i+1]=0;
  	input[i+2]=0;
  	input[i+3]=0;
     }
    // for 6 input instructions
    // 4 is 4 bytes i.e 32 bit

    long long int len  = 6*4;
    //and 6 output values
    // 4 is 4 bytes i.e 32 bit
    long long int lenr = 6*4;

    allwrite(fdw,input,len);
    allread(fdr,buf,lenr);
    int * out = (int *) buf;
    for(int i=0;i<12; i++)
	     printf(" \n %d ",*(out+i));
    printf(" done ");
return 0;
}

void allwrite(int fd, unsigned char *buf, int leng) {
    int sent = 0;
    int rc;
    long double t1;
    while (sent < leng) {
        rc = write(fd, buf + sent, leng - sent);

        if ((rc < 0) && (errno == EINTR))
            continue;

        if (rc < 0) {
            perror("allwrite() failed to write");
            exit(1);
        }

        if (rc == 0) {
            fprintf(stderr, "Reached write EOF (?!)\n");
            exit(1);
        }
        sent += rc;
    }
}

void allread(int fd, unsigned char *buf, int leng) {
    int readd = 0;
    int rc;

    while (readd < leng) {
        rc = read(fd, buf + readd, leng - readd);

        if ((rc < 0) && (errno == EINTR))
            continue;

        if (rc < 0) {
            perror("read() failed");
            exit(1);
        }

        if (rc == 0) {
            fprintf(stderr, "Reached read EOF!? Should never happen.\n");
            exit(0);
        }

        readd += rc;

    }

}
