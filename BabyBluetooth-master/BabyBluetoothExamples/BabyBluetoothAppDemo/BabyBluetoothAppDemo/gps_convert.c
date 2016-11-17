//
//  gps_convert.c
//  BabyBluetoothAppDemo
//
//  Created by ywl on 2016/11/16.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#include "gps_convert.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>


int ddmm2dd(const char *ddmm, char *dd, char *temp)
{
    if (NULL == ddmm || NULL == dd) {
        return -1;
    }
    unsigned long lenSrc = strlen(ddmm) + 1;
    int lenMm = 0;
    int flag = 1;
    
    memcpy(dd, ddmm, lenSrc);
    
    char *pcMm;
    double dMm;
    int iMm;
    
    pcMm = strstr(dd, ".");
    
    if (pcMm == NULL) {
        pcMm = dd+strlen(dd) - 2;
        iMm = atoi(pcMm);
        dMm = iMm /60.0;
    }
    else /* 含有小数点的情况 */
    {
        /* 有度 */
        if (pcMm - dd > 2)
        {
            pcMm = pcMm - 2;
        }
        else /* 没有度,只有分 */
        {
            pcMm = dd;
            flag = 0;
        }
        /* 将字符串转换为浮点数 */
        dMm = atof(pcMm);
        /* 将分转换为度 */
        dMm /= 60.0;
    }
    /* 把转换后的浮点数转换为字符串 */
    sprintf(pcMm,"%lf",dMm);
    if ( flag )
    {
        /* 去掉小数点前面的0 */
        lenSrc = strlen(pcMm) + 1;
        //        memcpy(temp, pcMm, strlen(pcMm) + 1);
        memcpy(temp, pcMm, lenSrc);
        strcpy(pcMm,temp+1);
    }
    /* 保留小数点后6位 */
    pcMm = strstr(dd,".");
    lenMm = strlen(pcMm);
    if ( lenMm > (6+2))
    {
        memset(pcMm+6+2,0,lenMm-6-2);
    }
    
    return 1;
    
}
