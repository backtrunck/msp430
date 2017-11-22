;******************************************************************************
;* MSP430 C/C++ Codegen                                      Unix v16.9.4.LTS *
;* Date/Time created: Sun Nov  5 10:03:59 2017                                *
;******************************************************************************
	.compiler_opts --abi=eabi --diag_wrap=off --hll_source=on --mem_model:code=large --mem_model:data=large --object_format=elf --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 --silicon_version=mspx --symdebug:none 
;	/opt/ti/ccsv7/tools/compiler/ti-cgt-msp430_16.9.4.LTS/bin/opt430 /tmp/TI3q5A3RCo3 /tmp/TI3q5urUjrl 
	.sect	".text:main"
	.clink
	.global	main
;----------------------------------------------------------------------
;  11 | int main(void)                                                         
;  13 | //WDTCTL = WDTPW | WDTHOLD;     // stop watchdog timer                 
;  15 | int i;                                                                 
;----------------------------------------------------------------------

;*****************************************************************************
;* FUNCTION NAME: main                                                       *
;*                                                                           *
;*   Regs Modified     : SP,SR,r11,r12,r13,r14,r15                           *
;*   Regs Used         : SP,SR,r11,r12,r13,r14,r15                           *
;*   Local Frame Size  : 0 Args + 0 Auto + 0 Save = 0 byte                   *
;*****************************************************************************
main:
;* --------------------------------------------------------------------------*
;----------------------------------------------------------------------
;  18 | i = ler_serial(5);                                                     
;----------------------------------------------------------------------
        MOV.W     #5,r12                ; [] |18| 
        CALLA     #ler_serial           ; [] |18| 
                                          ; [] |18| 
;----------------------------------------------------------------------
;  21 | return 0;                                                              
;----------------------------------------------------------------------
        MOV.W     #0,r12                ; [] |21| 
        RETA      ; [] 
        ; [] 
;*****************************************************************************
;* UNDEFINED EXTERNAL REFERENCES                                             *
;*****************************************************************************
	.global	ler_serial

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
