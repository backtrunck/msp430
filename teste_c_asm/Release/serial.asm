;******************************************************************************
;* MSP430 C/C++ Codegen                                      Unix v16.9.4.LTS *
;* Date/Time created: Sun Nov  5 10:06:44 2017                                *
;******************************************************************************
	.compiler_opts --abi=eabi --diag_wrap=off --hll_source=on --mem_model:code=large --mem_model:data=large --object_format=elf --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 --silicon_version=mspx --symdebug:none 
;	/opt/ti/ccsv7/tools/compiler/ti-cgt-msp430_16.9.4.LTS/bin/opt430 /tmp/TI3t3EYnCzr /tmp/TI3t3VL43ob 
	.sect	".text:ler_serial"
	.clink
	.global	ler_serial

;*****************************************************************************
;* FUNCTION NAME: ler_serial                                                 *
;*                                                                           *
;*   Regs Modified     : SP,SR,r12,r13,r14,r15                               *
;*   Regs Used         : SP,SR,r12,r13,r14,r15                               *
;*   Local Frame Size  : 0 Args + 0 Auto + 0 Save = 0 byte                   *
;*****************************************************************************
ler_serial:
;* --------------------------------------------------------------------------*
;----------------------------------------------------------------------
;   3 | int ler_serial(int i,int j){                                           
;----------------------------------------------------------------------
        MOVA      r12,r15               ; [] |3| 
        MOVA      r13,r12               ; [] |3| 
        MOVA      r15,r13               ; [] |3| 
;----------------------------------------------------------------------
;   6 | j = i * j;                                                             
;----------------------------------------------------------------------
        CALLA     #__mspabi_mpyi        ; [] |6| 
                                          ; [] |6| 
;----------------------------------------------------------------------
;   7 | return 2 * j;                                                          
;----------------------------------------------------------------------
        RLAM.W    #1,r12                ; [] |7| 
        RETA      ; [] 
        ; [] 
;*****************************************************************************
;* UNDEFINED EXTERNAL REFERENCES                                             *
;*****************************************************************************
	.global	__mspabi_mpyi

;******************************************************************************
;* BUILD ATTRIBUTES                                                           *
;******************************************************************************
	.battr "TI", Tag_File, 1, Tag_LPM_INFO(1)
	.battr "TI", Tag_File, 1, Tag_PORTS_INIT_INFO("012345678901ABCDEFGHIJ00000000000000000000000000000000000000000000")
	.battr "TI", Tag_File, 1, Tag_LEA_INFO(1)
	.battr "TI", Tag_File, 1, Tag_LOCKIO_INFO(1)
	.battr "TI", Tag_File, 1, Tag_WAITSTATE_INFO(2)
	.battr "TI", Tag_File, 1, Tag_HW_MPY32_INFO(1)
	.battr "TI", Tag_File, 1, Tag_HW_MPY_ISR_INFO(1)
	.battr "TI", Tag_File, 1, Tag_HW_MPY_INLINE_INFO(1)
	.battr "mspabi", Tag_File, 1, Tag_enum_size(3)
