// Tencent is pleased to support the open source community by making TNN available.
//
// Copyright (C) 2020 THL A29 Limited, a Tencent company. All rights reserved.
//
// Licensed under the BSD 3-Clause License (the "License"); you may not use this file except
// in compliance with the License. You may obtain a copy of the License at
//
// https://opensource.org/licenses/BSD-3-Clause
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the 
// specific language governing permissions and limitations under the License.


#ifdef __aarch64__

#include "tnn/device/arm/acc/compute/asm_func_name.S"

.text
.align 5

asm_function GEMM_FLOAT_N8
//void GEMM_FLOAT_N8(float* dst, const float* src, const float* weight, int src_depth_quad,
//                            int dst_step, int dst_depth_quad, int width, float *bias, int64_t relu)
//Auto Load:
//x0:dst, x1:src, x2:weight, x3:src_depth_quad, x4:dst_step, x5:dst_depth_quad, x6: width, x7: bias

.macro COMPUTE_UNIT_0 z0 z1 z2 z3 y
fmla \z0, \y, v0.s[0]
fmla \z1, \y, v0.s[1]
fmla \z2, \y, v0.s[2]
fmla \z3, \y, v0.s[3]
.endm

.macro COMPUTE_UNIT_1 z0 z1 z2 z3 y
fmla \z0, \y, v1.s[0]
fmla \z1, \y, v1.s[1]
fmla \z2, \y, v1.s[2]
fmla \z3, \y, v1.s[3]
.endm

.macro COMPUTE_UNIT_2 z0 z1 z2 z3 y
fmla \z0, \y, v2.s[0]
fmla \z1, \y, v2.s[1]
fmla \z2, \y, v2.s[2]
fmla \z3, \y, v2.s[3]
.endm

.macro COMPUTE_UNIT_3 z0 z1 z2 z3 y
fmla \z0, \y, v3.s[0]
fmla \z1, \y, v3.s[1]
fmla \z2, \y, v3.s[2]
fmla \z3, \y, v3.s[3]
.endm

//Load from sp


//step multi by sizeof(float)
mov x12, #4
mul x4, x12, x4

prfm pldl1keep, [x7]
sub sp, sp, #160
st1 {v8.4s, v9.4s, v10.4s, v11.4s}, [sp], #64
st1 {v12.4s, v13.4s, v14.4s, v15.4s}, [sp], #64
stp x19, x20, [sp], #16
stp x21, x22, [sp], #16

//x8: src_z_step
mov x12, #16
mul x8, x12, x6

//x9: weight_z_step
mov x12, #128
mul x9, x12, x3
mov x13, x3
mov x19, x6

LoopDz:
mov x10, x0
mov x14, x1
mov x15, x2
add x20, x2, x9
add x21, x0, x4

L12:
cmp x6, #11
ble L4
ld1 {v19.16b, v20.16b}, [x7]

mov x11, x1
mov x12, x2
ld1 {v0.4s, v1.4s}, [x1], #32
mov v8.16b, v19.16b
mov v9.16b, v19.16b
mov v10.16b, v19.16b
mov v11.16b, v19.16b
mov v12.16b, v19.16b
mov v13.16b, v19.16b
mov v14.16b, v19.16b
ld1 {v4.4s, v5.4s}, [x2], #32
mov v15.16b, v19.16b
mov v16.16b, v19.16b
mov v17.16b, v19.16b
mov v18.16b, v19.16b
mov v21.16b, v20.16b
mov v22.16b, v20.16b
mov v23.16b, v20.16b
mov v24.16b, v20.16b
mov v25.16b, v20.16b
mov v26.16b, v20.16b
mov v27.16b, v20.16b

mov v28.16b, v20.16b
mov v29.16b, v20.16b
mov v30.16b, v20.16b
mov v31.16b, v20.16b

L12Loop:
    prfm pldl1keep, [x1, #512]
	ld1 {v2.4s, v3.4s}, [x1], #32
    prfm pldl1keep, [x2, #512]
	
    COMPUTE_UNIT_0 v8.4s, v9.4s, v10.4s, v11.4s, v4.4s
	ld1 {v6.4s, v7.4s}, [x2], #32
    COMPUTE_UNIT_1 v12.4s, v13.4s, v14.4s, v15.4s, v4.4s
    COMPUTE_UNIT_0 v20.4s, v21.4s, v22.4s, v23.4s, v5.4s
    COMPUTE_UNIT_1 v24.4s, v25.4s, v26.4s, v27.4s, v5.4s

    ld1 {v0.4s, v1.4s}, [x1], #32
    COMPUTE_UNIT_2 v16.4s, v17.4s, v18.4s, v19.4s, v4.4s
    COMPUTE_UNIT_2 v28.4s, v29.4s, v30.4s, v31.4s, v5.4s
    
	ld1 {v4.4s, v5.4s}, [x2], #32
    COMPUTE_UNIT_3 v8.4s, v9.4s, v10.4s, v11.4s, v6.4s
    COMPUTE_UNIT_3 v20.4s, v21.4s, v22.4s, v23.4s, v7.4s

    prfm pldl1keep, [x1, #512]
	ld1 {v2.4s, v3.4s}, [x1], #32

    COMPUTE_UNIT_0 v12.4s, v13.4s, v14.4s, v15.4s, v6.4s
    COMPUTE_UNIT_1 v16.4s, v17.4s, v18.4s, v19.4s, v6.4s

    COMPUTE_UNIT_0 v24.4s, v25.4s, v26.4s, v27.4s, v7.4s
    COMPUTE_UNIT_1 v28.4s, v29.4s, v30.4s, v31.4s, v7.4s

    ld1 {v0.4s, v1.4s}, [x1], #32

    prfm pldl1keep, [x2, #512]
	ld1 {v6.4s, v7.4s}, [x2], #32

    COMPUTE_UNIT_2 v8.4s, v9.4s, v10.4s, v11.4s, v4.4s
    COMPUTE_UNIT_3 v12.4s, v13.4s, v14.4s, v15.4s, v4.4s

    COMPUTE_UNIT_2 v20.4s, v21.4s, v22.4s, v23.4s, v5.4s
    COMPUTE_UNIT_3 v24.4s, v25.4s, v26.4s, v27.4s, v5.4s
	
    prfm pldl1keep, [x1, #512]
    ld1 {v2.4s, v3.4s}, [x1], #32

    COMPUTE_UNIT_0 v16.4s, v17.4s, v18.4s, v19.4s, v4.4s
    COMPUTE_UNIT_0 v28.4s, v29.4s, v30.4s, v31.4s, v5.4s

	ld1 {v4.4s, v5.4s}, [x2], #32
    COMPUTE_UNIT_1 v8.4s, v9.4s, v10.4s, v11.4s, v6.4s
    COMPUTE_UNIT_1 v20.4s, v21.4s, v22.4s, v23.4s, v7.4s
    
    sub x1, x1, #192
    add x1, x1, x8
    ld1 {v0.4s, v1.4s}, [x1], #32

    COMPUTE_UNIT_2 v12.4s, v13.4s, v14.4s, v15.4s, v6.4s
    COMPUTE_UNIT_3 v16.4s, v17.4s, v18.4s, v19.4s, v6.4s

    subs x3, x3, #1

    COMPUTE_UNIT_2 v24.4s, v25.4s, v26.4s, v27.4s, v7.4s
    COMPUTE_UNIT_3 v28.4s, v29.4s, v30.4s, v31.4s, v7.4s

    bne L12Loop

    ldr x1, [sp, #0]
    cbz x1, Store12
    movi v0.4s, #0
    fmax   v8.4s, v8.4s, v0.4s
    fmax   v9.4s, v9.4s, v0.4s
    fmax   v10.4s, v10.4s, v0.4s
    fmax   v11.4s, v11.4s, v0.4s
    fmax   v12.4s, v12.4s, v0.4s
    fmax   v13.4s, v13.4s, v0.4s
    fmax   v14.4s, v14.4s, v0.4s
    fmax   v15.4s, v15.4s, v0.4s
    fmax   v16.4s,v16.4s,v0.4s
    fmax   v17.4s,v17.4s,v0.4s
    fmax   v18.4s, v18.4s, v0.4s
    fmax   v19.4s, v19.4s, v0.4s
    fmax   v20.4s, v20.4s, v0.4s
    fmax   v21.4s, v21.4s, v0.4s
    fmax   v22.4s, v22.4s, v0.4s
    fmax   v23.4s, v23.4s, v0.4s
    fmax   v24.4s,v24.4s,v0.4s
    fmax   v25.4s,v25.4s,v0.4s
    fmax   v26.4s, v26.4s, v0.4s
    fmax   v27.4s, v27.4s, v0.4s
    fmax   v28.4s, v28.4s, v0.4s
    fmax   v29.4s, v29.4s, v0.4s
    fmax   v30.4s, v30.4s, v0.4s
    fmax   v31.4s, v31.4s, v0.4s
Store12:
st1 {v8.4s, v9.4s, v10.4s, v11.4s}, [x0], #64
sub x6, x6, #12
st1 {v12.4s, v13.4s, v14.4s, v15.4s}, [x0], #64
st1 {v16.4s, v17.4s, v18.4s, v19.4s}, [x0], #64
st1 {v20.4s, v21.4s, v22.4s, v23.4s}, [x21], #64
st1 {v24.4s, v25.4s, v26.4s, v27.4s}, [x21], #64
st1 {v28.4s, v29.4s, v30.4s, v31.4s}, [x21], #64
cmp x6, #12


add x1, x11, #192
mov x2, x12
mov x3, x13
bge L12

L4:
cmp x6, #3
ble L1

ld1 {v15.16b, v16.16b}, [x7]
mov x11, x1
mov x12, x2
ld1 {v0.4s, v1.4s}, [x1], #32
mov v12.16b, v15.16b
mov v13.16b, v15.16b
ld1 {v4.4s, v5.4s}, [x2], #32
mov v14.16b, v15.16b
mov v17.16b, v16.16b
mov v18.16b, v16.16b
mov v19.16b, v16.16b
 

L4Loop:
    prfm pldl1keep, [x1, #512]
    ld1 {v2.4s, v3.4s}, [x1], #32
    prfm pldl1keep, [x2, #512]
    ld1 {v6.4s, v7.4s}, [x2], #32

    COMPUTE_UNIT_0 v12.4s, v13.4s, v14.4s, v15.4s, v4.4s
    ld1 {v8.4s, v9.4s}, [x2], #32
    COMPUTE_UNIT_0 v16.4s, v17.4s, v18.4s, v19.4s, v5.4s

    ld1 {v10.4s, v11.4s}, [x2], #32
    COMPUTE_UNIT_1 v12.4s, v13.4s, v14.4s, v15.4s, v6.4s
    
    ld1 {v4.4s, v5.4s}, [x2], #32
    sub x1, x1, #64
    add x1, x1, x8
    COMPUTE_UNIT_1 v16.4s, v17.4s, v18.4s, v19.4s, v7.4s

    ld1 {v0.4s, v1.4s}, [x1], #32

    prfm pldl1keep, [x2, #512]

    COMPUTE_UNIT_2 v12.4s, v13.4s, v14.4s, v15.4s, v8.4s
    COMPUTE_UNIT_2 v16.4s, v17.4s, v18.4s, v19.4s, v9.4s

    subs x3, x3, #1

    COMPUTE_UNIT_3 v12.4s, v13.4s, v14.4s, v15.4s, v10.4s
    COMPUTE_UNIT_3 v16.4s, v17.4s, v18.4s, v19.4s, v11.4s

    bne L4Loop
    ldr x1, [sp, #0]
    cbz x1, Store4
    movi v0.4s, #0
    fmax   v12.4s, v12.4s, v0.4s
    fmax   v13.4s, v13.4s, v0.4s
    fmax   v14.4s, v14.4s, v0.4s
    fmax   v15.4s, v15.4s, v0.4s
    fmax   v16.4s, v16.4s, v0.4s
    fmax   v17.4s, v17.4s, v0.4s
    fmax   v18.4s, v18.4s, v0.4s
    fmax   v19.4s, v19.4s, v0.4s
Store4:
st1 {v12.4s, v13.4s, v14.4s, v15.4s}, [x0], #64
st1 {v16.4s, v17.4s, v18.4s, v19.4s}, [x21], #64

subs x6, x6, #4
cmp x6, #4
add x1, x11, #64
mov x2, x12
mov x3, x13
bge L4

L1:
cmp x6, #0
ble End

L1Loop:
    ld1 {v17.4s, v18.4s}, [x7]
    mov x11, x1
    mov x12, x2
    prfm pldl1keep, [x2, #512]
    ld1 {v0.4s}, [x1], x8
    ld1 {v2.4s, v3.4s, v4.4s, v5.4s}, [x2], #64
	ld1 {v24.4s, v25.4s, v26.4s, v27.4s}, [x2], #64
    fmul v16.4s, v2.4s, v0.s[0]
    fmla v18.4s, v3.4s, v0.s[0]
    subs x3, x3, #1
    fmla v17.4s, v4.4s, v0.s[1]
	fmul v19.4s, v5.4s, v0.s[1]

    beq L1LoopZEnd

    L1LoopZ:
        fmla v16.4s, v24.4s, v0.s[2]
        fmla v18.4s, v25.4s, v0.s[2]
        fmla v17.4s, v26.4s, v0.s[3]
        fmla v19.4s, v27.4s, v0.s[3]

        prfm pldl1keep, [x2, #512]
        ld1 {v0.4s}, [x1], x8
        ld1 {v2.4s, v3.4s, v4.4s, v5.4s}, [x2], #64
	    ld1 {v24.4s, v25.4s, v26.4s, v27.4s}, [x2], #64
        fmla v16.4s, v2.4s, v0.s[0]
        fmla v18.4s, v3.4s, v0.s[0]
        fmla v17.4s, v4.4s, v0.s[1]
        fmla v19.4s, v5.4s, v0.s[1]

        subs x3, x3, #1
        bne L1LoopZ
    L1LoopZEnd:

    fmla v16.4s, v24.4s, v0.s[2]
    fmla v18.4s, v25.4s, v0.s[2]
	fmla v17.4s, v26.4s, v0.s[3]
    fmla v19.4s, v27.4s, v0.s[3]

    fadd v16.4s, v16.4s, v17.4s
	fadd v18.4s, v18.4s, v19.4s
    ldr x1, [sp, #0]
    cbz x1, Store1
    movi v0.4s, #0
    fmax   v16.4s, v16.4s, v0.4s
    fmax   v18.4s, v18.4s, v0.4s
Store1:
    add x1, x11, #16
    mov x2, x12
    mov x3, x13
    subs x6, x6, #1
    st1 {v16.4s}, [x0], #16
	st1 {v18.4s}, [x21], #16
    bne L1Loop

	
End:

subs x5, x5, #2
add x0, x10, x4
mov x1, x14
add x7, x7, #32
add x2, x15, x9
add x0, x0, x4
mov x6, x19
bne LoopDz

sub sp, sp, #160
ld1 {v8.4s, v9.4s, v10.4s, v11.4s}, [sp], #64
ld1 {v12.4s, v13.4s, v14.4s, v15.4s}, [sp], #64
ldp x19, x20, [sp], #16
ldp x21, x22, [sp], #16

ret

#endif
