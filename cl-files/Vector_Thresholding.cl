////////////////////////////////////////////////////////////////////////////////
//! @file	: Vector_Thresholding.cl
//! @date   : Mar 2014
//!
//! @brief  : Thresholding operations on image buffers
//! 
//! Copyright (C) 2014 - CRVI
//!
//! This file is part of OpenCLIPP.
//! 
//! OpenCLIPP is free software: you can redistribute it and/or modify
//! it under the terms of the GNU Lesser General Public License version 3
//! as published by the Free Software Foundation.
//! 
//! OpenCLIPP is distributed in the hope that it will be useful,
//! but WITHOUT ANY WARRANTY; without even the implied warranty of
//! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//! GNU Lesser General Public License for more details.
//! 
//! You should have received a copy of the GNU Lesser General Public License
//! along with OpenCLIPP.  If not, see <http://www.gnu.org/licenses/>.
//! 
////////////////////////////////////////////////////////////////////////////////

#include "Vector.h"

kernel void thresholdLT(INPUT_SPACE const TYPE * source, global TYPE * dest, int src_step, int dst_step, int width, float thresh, float valueLower)
{
   BEGIN
   LAST_WORKER(src < thresh ? valueLower : src)
   PREPARE_VECTOR
   VECTOR_OP(src < (TYPE)((SCALAR)thresh) ? (DST)((DST_SCALAR)valueLower) : src);
}

kernel void thresholdGT(INPUT_SPACE const TYPE * source, global TYPE * dest, int src_step, int dst_step, int width, float thresh, float valueHigher)
{
   BEGIN
   LAST_WORKER(src > thresh ? valueHigher : src)
   PREPARE_VECTOR
   VECTOR_OP(src > (TYPE)((SCALAR)thresh) ? (DST)((DST_SCALAR)valueHigher) : src);
}

kernel void thresholdGTLT(INPUT_SPACE const TYPE * source, global TYPE * dest, int src_step, int dst_step, int width, 
                    float threshLT, float valueLower, float threshGT, float valueHigher)
{
   BEGIN
   LAST_WORKER(src < threshLT ? valueLower : (src > threshGT ? valueHigher : src))
   PREPARE_VECTOR
   VECTOR_OP(src < (TYPE)((SCALAR)threshLT) ? (DST)((DST_SCALAR)valueLower) : (src > (TYPE)((SCALAR)threshGT) ? (DST)((DST_SCALAR)valueHigher) : src));
}

BINARY_OP(img_thresh_LT, (src1 <  src2 ? src1 : src2))
BINARY_OP(img_thresh_LQ, (src1 <= src2 ? src1 : src2))
BINARY_OP(img_thresh_EQ, (src1 == src2 ? src1 : src2))
BINARY_OP(img_thresh_GQ, (src1 >= src2 ? src1 : src2))
BINARY_OP(img_thresh_GT, (src1 >  src2 ? src1 : src2))



// The following kernels will receive an unsigned char (U8) image for destination
#undef DST_SCALAR
#undef DST
#define DST_SCALAR uchar
#define DST CONCATENATE(DST_SCALAR, VEC_WIDTH)

#define TST_TYPE CONCATENATE(uint, VEC_WIDTH)

#undef CONVERT_DST
#undef CONVERT_DST_SCALAR
#define CONVERT_DST(val) CONCATENATE(CONCATENATE(convert_, DST), _sat) (val)
#define CONVERT_DST_SCALAR(val) (val)

#define WHITE ((INTERNAL)(255))
#define BLACK ((INTERNAL)(0))

#ifdef SCALAR_OP
#undef SCALAR_OP
#endif
#define SCALAR_OP(code) WRITE_SCALAR(dst_scalar, dst_step, i, gy, (code).x)


BINARY_OP(img_compare_LT, (src1 <  src2 ? WHITE : BLACK))
BINARY_OP(img_compare_LQ, (src1 <= src2 ? WHITE : BLACK))
BINARY_OP(img_compare_EQ, (src1 == src2 ? WHITE : BLACK))
BINARY_OP(img_compare_GQ, (src1 >= src2 ? WHITE : BLACK))
BINARY_OP(img_compare_GT, (src1 >  src2 ? WHITE : BLACK))

CONSTANT_OP(compare_LT, (src <  value ? WHITE : BLACK))
CONSTANT_OP(compare_LQ, (src <= value ? WHITE : BLACK))
CONSTANT_OP(compare_EQ, (src == value ? WHITE : BLACK))
CONSTANT_OP(compare_GQ, (src >= value ? WHITE : BLACK))
CONSTANT_OP(compare_GT, (src >  value ? WHITE : BLACK))