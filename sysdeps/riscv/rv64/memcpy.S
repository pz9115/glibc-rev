/* The assembly function for memcpy.  RISC-V version.
   Copyright (C) 2018 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <http://www.gnu.org/licenses/>.  */

#include <sysdep.h>

#define LABLE_ALIGN   \
	.align 4

#if defined(__riscv_v) && (__riscv_v >= 1000000)
# define VLDB vle8.v
# define VSTB vse8.v
#else
# define VLDB vlb.v
# define VSTB vsb.v
#endif

ENTRY (memcpy)
#if defined(__riscv_vector)
	mv	a3, a0
	sltiu	a4, a2, 16
	bnez	a4, .loop_cpy
	andi	a5, a0, 15
	li	a6, 16
	beqz	a5, .loop_cpy
	sub	a5, a6, a5
	vsetvli	t0, a5, e8, m4
	VLDB	v0, (a1)
	add	a1, a1, t0
	sub	a2, a2, t0
	VSTB	v0, (a3)
	add	a3, a3, t0
.loop_cpy:
	vsetvli	t0, a2, e8, m4
	VLDB	v0, (a1)
	add	a1, a1, t0
	sub	a2, a2, t0
	VSTB	v0, (a3)
	add	a3, a3, t0
	bnez	a2, .loop_cpy
	ret
#else
	/* Test if len less than 32 bytes.  */
	mv      t6, a0
	sltiu   a3, a2, 8
	bnez    a3, .L_copy_by_byte

	srli    t4, a2, 6
	beqz     t4, .L_len_less_64bytes

	andi    a3, a0, 7
	li     t5, 8
	/* Test if dest is not 8 bytes aligned.  */
	bnez    a3, .L_dest_not_aligned

/* [128, +Inf) */
.L_len_larger_128bytes:
	srli    t4, a2, 7
	beqz     t4, .L_len_less_128bytes
	andi    a2, a2, 127
	LABLE_ALIGN
.L_len_larger_128bytes_loop:
	addi	t4, t4, -1
#if defined(__riscv_xtheadc)
	th.ldd	a4, a5, 0(a1)
	th.sdd	a4, a5, 0(a0)
	th.ldd	a6, a7, 16(a1)
	th.sdd	a6, a7, 16(a0)
	th.ldd	a4, a5, 32(a1)
	th.sdd	a4, a5, 32(a0)
	th.ldd	a6, a7, 48(a1)
	th.sdd	a6, a7, 48(a0)
	addi    a1, a1, 64
	addi    a0, a0, 64
	th.ldd	a4, a5, 0(a1)
	th.sdd	a4, a5, 0(a0)
	th.ldd	a6, a7, 16(a1)
	th.sdd	a6, a7, 16(a0)
	th.ldd	a4, a5, 32(a1)
	th.sdd	a4, a5, 32(a0)
	th.ldd	a6, a7, 48(a1)
	th.sdd	a6, a7, 48(a0)
	addi    a1, a1, 64
	addi    a0, a0, 64
#else
	ld      a4, 0(a1)
	sd      a4, 0(a0)
	ld      a5, 8(a1)
	sd      a5, 8(a0)
	ld      a6, 16(a1)
	sd      a6, 16(a0)
	ld      a7, 24(a1)
	sd      a7, 24(a0)
	ld      a4, 32(a1)
	sd      a4, 32(a0)
	ld      a5, 40(a1)
	sd      a5, 40(a0)
	ld      a6, 48(a1)
	sd      a6, 48(a0)
	ld      a7, 56(a1)
	sd      a7, 56(a0)
	ld      a4, 64(a1)
	sd      a4, 64(a0)
	ld      a5, 72(a1)
	sd      a5, 72(a0)
	ld      a6, 80(a1)
	sd      a6, 80(a0)
	ld      a7, 88(a1)
	sd      a7, 88(a0)
	ld      a4, 96(a1)
	sd      a4, 96(a0)
	ld      a5, 104(a1)
	sd      a5, 104(a0)
	ld      a6, 112(a1)
	sd      a6, 112(a0)
	ld      a7, 120(a1)
	sd      a7, 120(a0)
	addi    a1, a1, 128
	addi    a0, a0, 128
#endif
	bnez	t4, .L_len_larger_128bytes_loop

/* [64, 128) */
.L_len_less_128bytes:
	srli    t4, a2, 6
	beqz     t4, .L_len_less_64bytes
	andi    a2, a2, 63
#if defined(__riscv_xtheadc)
	th.ldd	a4, a5, 0(a1)
	th.sdd	a4, a5, 0(a0)
	th.ldd	a6, a7, 16(a1)
	th.sdd	a6, a7, 16(a0)
	th.ldd	a4, a5, 32(a1)
	th.sdd	a4, a5, 32(a0)
	th.ldd	a6, a7, 48(a1)
	th.sdd	a6, a7, 48(a0)
#else
	ld      a4, 0(a1)
	sd      a4, 0(a0)
	ld      a5, 8(a1)
	sd      a5, 8(a0)
	ld      a6, 16(a1)
	sd      a6, 16(a0)
	ld      a7, 24(a1)
	sd      a7, 24(a0)
	ld      a4, 32(a1)
	sd      a4, 32(a0)
	ld      a5, 40(a1)
	sd      a5, 40(a0)
	ld      a6, 48(a1)
	sd      a6, 48(a0)
	ld      a7, 56(a1)
	sd      a7, 56(a0)
#endif
	addi    a1, a1, 64
	addi    a0, a0, 64


/* [16, 64). */
.L_len_less_64bytes:
	srli    t4, a2, 4
	beqz     t4, .L_len_less_16bytes
	andi    a2, a2, 15
.L_len_less_64bytes_loop:
	addi	t4, t4, -1
#if defined(__riscv_xtheadc)
	th.ldd	a4, a5, 0(a1)
	th.sdd	a4, a5, 0(a0)
#else
	ld      a4, 0(a1)
	sd      a4, 0(a0)
	ld      a5, 8(a1)
	sd      a5, 8(a0)
#endif
	addi    a1, a1, 16
	addi    a0, a0, 16
	bnez    t4, .L_len_less_64bytes_loop

/* [8, 16). */
.L_len_less_16bytes:
	srli    t4, a2, 3
	beqz     t4, .L_len_less_8bytes
	andi    a2, a2, 7
#if defined(__riscv_xtheadc)
	ldia	a4, (a1), 8, 0
	sdia	a4, (a0), 8, 0
#else
	ld      a4, 0(a1)
	addi    a1, a1, 8
	sd      a4, 0(a0)
	addi    a0, a0, 8
#endif

/* [4, 8). */
.L_len_less_8bytes:
	srli    t4, a2, 2
	beqz     t4, .L_copy_by_byte
	andi    a2, a2, 3
#if defined(__riscv_xtheadc)
	lwia	a4, (a1), 4, 0
	swia	a4, (a0), 4, 0
#else
	lw      a4, 0(a1)
	addi    a1, a1, 4
	sw      a4, 0(a0)
	addi    a0, a0, 4
#endif

/* [0, 32). Copy tail.  */
.L_copy_by_byte:
	andi    a2, a2, 7
	beqz     a2, .L_return
.L_copy_by_byte_loop:
	addi	a2, a2, -1
#if defined(__riscv_xtheadc)
	lbia	a4, (a1), 1, 0
	sbia	a4, (a0), 1, 0
#else
	lb     a4, 0(a1)
	addi    a1, a1, 1
	sb     a4, 0(a0)
	addi    a0, a0, 1
#endif
	bnez	a2, .L_copy_by_byte_loop

.L_return:
	mv      a0, t6
	ret

	/* If dest is not aligned, just copying some bytes makes the dest
	   align.  */
.L_dest_not_aligned:
	sub     a3, t5, a3
	mv      t5, a3
.L_dest_not_aligned_loop:
	/* Makes the dest align.  */
	addi	a3, a3, -1
#if defined(__riscv_xtheadc)
	lbia	a4, (a1), 1, 0
	sbia	a4, (a0), 1, 0
#else
	lb     a4, 0(a1)
	addi    a1, a1, 1
	sb     a4, 0(a0)
	addi    a0, a0, 1
#endif
	bnez	a3, .L_dest_not_aligned_loop
	sub     a2, a2, t5
	sltiu	a3, a2, 4
	bnez    a3, .L_copy_by_byte
	/* Check whether the src is aligned.  */
	j		.L_len_larger_128bytes
#endif
END (memcpy)

libc_hidden_builtin_def (memcpy)
.weak HIDDEN_JUMPTARGET (memcpy)

ENTRY (memmove)
#if defined(__riscv_vector)
	sub	a3, a0, a1
	bgeu	a3, a2, memcpy
	add	a3, a0, a2
	add	a1, a1, a2
	sltiu	a4, a2, 16
	bnez	a4, .loop_move
	andi	a5, a0, 15
	beqz	a5, .loop_move
	vsetvli	t0, a5, e8, m4
	sub	a1, a1, t0
	VLDB	v0, (a1)
	sub	a3, a3, t0
	sub	a2, a2, t0
	VSTB	v0, (a3)
.loop_move:
	vsetvli t0, a2, e8, m4
	sub	a1, a1, t0
	VLDB	v0, (a1)
	sub	a3, a3, t0
	sub	a2, a2, t0
	VSTB	v0, (a3)
	bnez	a2, .loop_move
	ret
#else
	sub	a3, a0, a1
	bgeu	a3, a2, memcpy

	mv	t6, a0
	add	a0, a0, a2
	add	a1, a1, a2

	/* Test if len less than 8 bytes.  */
	sltiu	a3, a2, 8
	bnez	a3, .L_copy_by_byte_m
	srli	t4, a2, 6
	beqz	t4, .L_len_less_64bytes_m

	andi	t5, a0, 7
	/* Test if dest is not 8 bytes aligned.  */
	bnez	t5, .L_dest_not_aligned_m

/* [128, +Inf) */
.L_len_larger_128bytes_m:
	srli    t4, a2, 7
	beqz     t4, .L_len_less_128bytes_m
	andi    a2, a2, 127
	LABLE_ALIGN
.L_len_larger_128bytes_loop_m:
	addi	t4, t4, -1
#if defined(__riscv_xtheadc)
	addi	a1, a1, -64
	addi	a0, a0, -64
	th.ldd	a6, a7, 48(a1)
	th.sdd	a6, a7, 48(a0)
	th.ldd	a4, a5, 32(a1)
	th.sdd	a4, a5, 32(a0)
	th.ldd	a6, a7, 16(a1)
	th.sdd	a6, a7, 16(a0)
	th.ldd	a4, a5, 0(a1)
	th.sdd	a4, a5, 0(a0)
	addi	a1, a1, -64
	addi	a0, a0, -64
	th.ldd	a6, a7, 48(a1)
	th.sdd	a6, a7, 48(a0)
	th.ldd	a4, a5, 32(a1)
	th.sdd	a4, a5, 32(a0)
	th.ldd	a6, a7, 16(a1)
	th.sdd	a6, a7, 16(a0)
	th.ldd	a4, a5, 0(a1)
	th.sdd	a4, a5, 0(a0)
#else
	addi	a1, a1, -128
	addi	a0, a0, -128
	ld      a7, 120(a1)
	sd      a7, 120(a0)
	ld      a6, 112(a1)
	sd      a6, 112(a0)
	ld      a5, 104(a1)
	sd      a5, 104(a0)
	ld      a4, 96(a1)
	sd      a4, 96(a0)
	ld      a7, 88(a1)
	sd      a7, 88(a0)
	ld      a6, 80(a1)
	sd      a6, 80(a0)
	ld      a5, 72(a1)
	sd      a5, 72(a0)
	ld      a3, 64(a1)
	sd      a3, 64(a0)
	ld      a7, 56(a1)
	sd      a7, 56(a0)
	ld      a6, 48(a1)
	sd      a6, 48(a0)
	ld      a5, 40(a1)
	sd      a5, 40(a0)
	ld      a4, 32(a1)
	sd      a4, 32(a0)
	ld      a7, 24(a1)
	sd      a7, 24(a0)
	ld      a6, 16(a1)
	sd      a6, 16(a0)
	ld      a5, 8(a1)
	sd      a5, 8(a0)
	ld      a3, 0(a1)
	sd      a3, 0(a0)
#endif
	bnez	t4,.L_len_larger_128bytes_loop_m

/* [64, 128) */
.L_len_less_128bytes_m:
	srli    t4, a2, 6
	beqz     t4, .L_len_less_64bytes_m
	andi    a2, a2, 63
	addi	a1, a1, -64
	addi	a0, a0, -64
#if defined(__riscv_xtheadc)
	th.ldd	a6, a7, 48(a1)
	th.sdd	a6, a7, 48(a0)
	th.ldd	a4, a5, 32(a1)
	th.sdd	a4, a5, 32(a0)
	th.ldd	a6, a7, 16(a1)
	th.sdd	a6, a7, 16(a0)
	th.ldd	a4, a5, 0(a1)
	th.sdd	a4, a5, 0(a0)
#else
	ld      a7, 56(a1)
	sd      a7, 56(a0)
	ld      a6, 48(a1)
	sd      a6, 48(a0)
	ld      a5, 40(a1)
	sd      a5, 40(a0)
	ld      a4, 32(a1)
	sd      a4, 32(a0)
	ld      a7, 24(a1)
	sd      a7, 24(a0)
	ld      a6, 16(a1)
	sd      a6, 16(a0)
	ld      a5, 8(a1)
	sd      a5, 8(a0)
	ld      a3, 0(a1)
	sd      a3, 0(a0)
#endif

/* [16, 64). */
.L_len_less_64bytes_m:
	srli    t4, a2, 4
	beqz     t4, .L_len_less_16bytes_m
	andi    a2, a2, 15
.L_len_less_64bytes_loop_m:
	addi	t4, t4, -1
	addi	a1, a1, -16
	addi	a0, a0, -16
#if defined(__riscv_xtheadc)
	th.ldd	a4, a5, 0(a1)
	th.sdd	a4, a5, 0(a0)
#else
	ld      a4, 8(a1)
	sd      a4, 8(a0)
	ld      a5, 0(a1)
	sd      a5, 0(a0)
#endif
	bnez    t4, .L_len_less_64bytes_loop_m

/* [8, 16). */
.L_len_less_16bytes_m:
	srli    t4, a2, 3
	beqz     t4, .L_len_less_8bytes_m
	andi    a2, a2, 7
#if defined(__riscv_xtheadc)
	ldib	a4, (a1), -8, 0
	sdib	a4, (a0), -8, 0
#else
	addi	a1, a1, -8
	addi	a0, a0, -8
	ld      a4, 0(a1)
	sd      a4, 0(a0)
#endif

/* [4, 8). */
.L_len_less_8bytes_m:
	srli    t4, a2, 2
	beqz     t4, .L_copy_by_byte_m
	andi    a2, a2, 3
#if defined(__riscv_xtheadc)
	lwib	a4, (a1), -4, 0
	swib	a4, (a0), -4, 0
#else
	addi	a1, a1, -4
	addi	a0, a0, -4
	lw      a4, 0(a1)
	sw      a4, 0(a0)
#endif

/* [0, 32). Copy tail.  */
.L_copy_by_byte_m:
	andi    t4, a2, 7
	beqz	t4, .L_return_m
.L_copy_by_byte_loop_m:
	addi     t4, t4, -1
#if defined(__riscv_xtheadc)
	lbib	a3, (a1), -1, 0
	sbib	a3, (a0), -1, 0
#else
	addi	a1, a1, -1
	addi	a0, a0, -1
	lb	a3, 0(a1)
	sb	a3, 0(a0)
#endif
	bnez    t4, .L_copy_by_byte_loop_m

.L_return_m:
	mv	a0, t6
	ret

	/* If dest is not aligned, just copying some bytes makes the dest
	   align.  */
.L_dest_not_aligned_m:
	sub	a2, a2, t5
.L_dest_not_aligned_loop_m:
	addi     t5, t5, -1
	/* Makes the dest align.  */
#if defined(__riscv_xtheadc)
	lbib	a3, (a1), -1, 0
	sbib	a3, (a0), -1, 0
#else
	addi	a1, a1, -1
	addi	a0, a0, -1
	lb	a3, 0(a1)
	sb	a3, 0(a0)
#endif
	bnez	t5, .L_dest_not_aligned_loop_m
	sltiu   a3, a2, 4
	bnez    a3, .L_copy_by_byte_m
	/* Check whether the src is aligned.  */
	j	.L_len_larger_128bytes_m
#endif
END (memmove)

libc_hidden_builtin_def (memmove)
.weak memmove
