/*
 * File:    mcf548x_psc.h
 * Purpose: Register and bit definitions
 */

#ifndef __MCF548X_PSC_H__
#define __MCF548X_PSC_H__

/*********************************************************************
*
* Programmable Serial Controller (PSC)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_PSC0_MR                 (*(vuint8 *)(&__MBAR[0x008600]))
#define MCF_PSC0_SR                 (*(vuint16*)(&__MBAR[0x008604]))
#define MCF_PSC0_CSR                (*(vuint8 *)(&__MBAR[0x008604]))
#define MCF_PSC0_CR                 (*(vuint8 *)(&__MBAR[0x008608]))
#define MCF_PSC0_RB                 (*(vuint32*)(&__MBAR[0x00860C]))
#define MCF_PSC0_TB                 (*(vuint32*)(&__MBAR[0x00860C]))
#define MCF_PSC_TB0_8BIT            (*(vuint8 *)(&__MBAR[0x00860C]))
#define MCF_PSC_TB0_16BIT           (*(vuint16*)(&__MBAR[0x00860C]))
#define MCF_PSC_TB0_32BIT           (*(vuint32*)(&__MBAR[0x00860C]))
#define MCF_PSC_TB0_AC97            (*(vuint32*)(&__MBAR[0x00860C]))
#define MCF_PSC0_IPCR               (*(vuint8 *)(&__MBAR[0x008610]))
#define MCF_PSC0_ACR                (*(vuint8 *)(&__MBAR[0x008610]))
#define MCF_PSC0_ISR                (*(vuint16*)(&__MBAR[0x008614]))
#define MCF_PSC0_IMR                (*(vuint16*)(&__MBAR[0x008614]))
#define MCF_PSC0_CTUR               (*(vuint8 *)(&__MBAR[0x008618]))
#define MCF_PSC0_CTLR               (*(vuint8 *)(&__MBAR[0x00861C]))
#define MCF_PSC0_IP                 (*(vuint8 *)(&__MBAR[0x008634]))
#define MCF_PSC0_OPSET              (*(vuint8 *)(&__MBAR[0x008638]))
#define MCF_PSC0_OPRESET            (*(vuint8 *)(&__MBAR[0x00863C]))
#define MCF_PSC0_SICR               (*(vuint8 *)(&__MBAR[0x008640]))
#define MCF_PSC0_IRCR1              (*(vuint8 *)(&__MBAR[0x008644]))
#define MCF_PSC0_IRCR2              (*(vuint8 *)(&__MBAR[0x008648]))
#define MCF_PSC0_IRSDR              (*(vuint8 *)(&__MBAR[0x00864C]))
#define MCF_PSC0_IRMDR              (*(vuint8 *)(&__MBAR[0x008650]))
#define MCF_PSC0_IRFDR              (*(vuint8 *)(&__MBAR[0x008654]))
#define MCF_PSC0_RFCNT              (*(vuint16*)(&__MBAR[0x008658]))
#define MCF_PSC0_TFCNT              (*(vuint16*)(&__MBAR[0x00865C]))
#define MCF_PSC0_RFSR               (*(vuint16*)(&__MBAR[0x008664]))
#define MCF_PSC0_TFSR               (*(vuint16*)(&__MBAR[0x008684]))
#define MCF_PSC0_RFCR               (*(vuint32*)(&__MBAR[0x008668]))
#define MCF_PSC0_TFCR               (*(vuint32*)(&__MBAR[0x008688]))
#define MCF_PSC0_RFAR               (*(vuint16*)(&__MBAR[0x00866E]))
#define MCF_PSC0_TFAR               (*(vuint16*)(&__MBAR[0x00868E]))
#define MCF_PSC0_RFRP               (*(vuint16*)(&__MBAR[0x008672]))
#define MCF_PSC0_TFRP               (*(vuint16*)(&__MBAR[0x008692]))
#define MCF_PSC0_RFWP               (*(vuint16*)(&__MBAR[0x008676]))
#define MCF_PSC0_TFWP               (*(vuint16*)(&__MBAR[0x008696]))
#define MCF_PSC0_RLRFP              (*(vuint16*)(&__MBAR[0x00867A]))
#define MCF_PSC0_TLRFP              (*(vuint16*)(&__MBAR[0x00869A]))
#define MCF_PSC0_RLWFP              (*(vuint16*)(&__MBAR[0x00867E]))
#define MCF_PSC0_TLWFP              (*(vuint16*)(&__MBAR[0x00869E]))
#define MCF_PSC1_MR                 (*(vuint8 *)(&__MBAR[0x008700]))
#define MCF_PSC1_SR                 (*(vuint16*)(&__MBAR[0x008704]))
#define MCF_PSC1_CSR                (*(vuint8 *)(&__MBAR[0x008704]))
#define MCF_PSC1_CR                 (*(vuint8 *)(&__MBAR[0x008708]))
#define MCF_PSC1_RB                 (*(vuint32*)(&__MBAR[0x00870C]))
#define MCF_PSC1_TB                 (*(vuint32*)(&__MBAR[0x00870C]))
#define MCF_PSC_TB1_8BIT            (*(vuint8 *)(&__MBAR[0x00870C]))
#define MCF_PSC_TB1_16BIT           (*(vuint16*)(&__MBAR[0x00870C]))
#define MCF_PSC_TB1_32BIT           (*(vuint32*)(&__MBAR[0x00870C]))
#define MCF_PSC_TB1_AC97            (*(vuint32*)(&__MBAR[0x00870C]))
#define MCF_PSC1_IPCR               (*(vuint8 *)(&__MBAR[0x008710]))
#define MCF_PSC1_ACR                (*(vuint8 *)(&__MBAR[0x008710]))
#define MCF_PSC1_ISR                (*(vuint16*)(&__MBAR[0x008714]))
#define MCF_PSC1_IMR                (*(vuint16*)(&__MBAR[0x008714]))
#define MCF_PSC1_CTUR               (*(vuint8 *)(&__MBAR[0x008718]))
#define MCF_PSC1_CTLR               (*(vuint8 *)(&__MBAR[0x00871C]))
#define MCF_PSC1_IP                 (*(vuint8 *)(&__MBAR[0x008734]))
#define MCF_PSC1_OPSET              (*(vuint8 *)(&__MBAR[0x008738]))
#define MCF_PSC1_OPRESET            (*(vuint8 *)(&__MBAR[0x00873C]))
#define MCF_PSC1_SICR               (*(vuint8 *)(&__MBAR[0x008740]))
#define MCF_PSC1_IRCR1              (*(vuint8 *)(&__MBAR[0x008744]))
#define MCF_PSC1_IRCR2              (*(vuint8 *)(&__MBAR[0x008748]))
#define MCF_PSC1_IRSDR              (*(vuint8 *)(&__MBAR[0x00874C]))
#define MCF_PSC1_IRMDR              (*(vuint8 *)(&__MBAR[0x008750]))
#define MCF_PSC1_IRFDR              (*(vuint8 *)(&__MBAR[0x008754]))
#define MCF_PSC1_RFCNT              (*(vuint16*)(&__MBAR[0x008758]))
#define MCF_PSC1_TFCNT              (*(vuint16*)(&__MBAR[0x00875C]))
#define MCF_PSC1_RFSR               (*(vuint16*)(&__MBAR[0x008764]))
#define MCF_PSC1_TFSR               (*(vuint16*)(&__MBAR[0x008784]))
#define MCF_PSC1_RFCR               (*(vuint32*)(&__MBAR[0x008768]))
#define MCF_PSC1_TFCR               (*(vuint32*)(&__MBAR[0x008788]))
#define MCF_PSC1_RFAR               (*(vuint16*)(&__MBAR[0x00876E]))
#define MCF_PSC1_TFAR               (*(vuint16*)(&__MBAR[0x00878E]))
#define MCF_PSC1_RFRP               (*(vuint16*)(&__MBAR[0x008772]))
#define MCF_PSC1_TFRP               (*(vuint16*)(&__MBAR[0x008792]))
#define MCF_PSC1_RFWP               (*(vuint16*)(&__MBAR[0x008776]))
#define MCF_PSC1_TFWP               (*(vuint16*)(&__MBAR[0x008796]))
#define MCF_PSC1_RLRFP              (*(vuint16*)(&__MBAR[0x00877A]))
#define MCF_PSC1_TLRFP              (*(vuint16*)(&__MBAR[0x00879A]))
#define MCF_PSC1_RLWFP              (*(vuint16*)(&__MBAR[0x00877E]))
#define MCF_PSC1_TLWFP              (*(vuint16*)(&__MBAR[0x00879E]))
#define MCF_PSC2_MR                 (*(vuint8 *)(&__MBAR[0x008800]))
#define MCF_PSC2_SR                 (*(vuint16*)(&__MBAR[0x008804]))
#define MCF_PSC2_CSR                (*(vuint8 *)(&__MBAR[0x008804]))
#define MCF_PSC2_CR                 (*(vuint8 *)(&__MBAR[0x008808]))
#define MCF_PSC2_RB                 (*(vuint32*)(&__MBAR[0x00880C]))
#define MCF_PSC2_TB                 (*(vuint32*)(&__MBAR[0x00880C]))
#define MCF_PSC_TB2_8BIT            (*(vuint8 *)(&__MBAR[0x00880C]))
#define MCF_PSC_TB2_16BIT           (*(vuint16*)(&__MBAR[0x00880C]))
#define MCF_PSC_TB2_32BIT           (*(vuint32*)(&__MBAR[0x00880C]))
#define MCF_PSC_TB2_AC97            (*(vuint32*)(&__MBAR[0x00880C]))
#define MCF_PSC2_IPCR               (*(vuint8 *)(&__MBAR[0x008810]))
#define MCF_PSC2_ACR                (*(vuint8 *)(&__MBAR[0x008810]))
#define MCF_PSC2_ISR                (*(vuint16*)(&__MBAR[0x008814]))
#define MCF_PSC2_IMR                (*(vuint16*)(&__MBAR[0x008814]))
#define MCF_PSC2_CTUR               (*(vuint8 *)(&__MBAR[0x008818]))
#define MCF_PSC2_CTLR               (*(vuint8 *)(&__MBAR[0x00881C]))
#define MCF_PSC2_IP                 (*(vuint8 *)(&__MBAR[0x008834]))
#define MCF_PSC2_OPSET              (*(vuint8 *)(&__MBAR[0x008838]))
#define MCF_PSC2_OPRESET            (*(vuint8 *)(&__MBAR[0x00883C]))
#define MCF_PSC2_SICR               (*(vuint8 *)(&__MBAR[0x008840]))
#define MCF_PSC2_IRCR1              (*(vuint8 *)(&__MBAR[0x008844]))
#define MCF_PSC2_IRCR2              (*(vuint8 *)(&__MBAR[0x008848]))
#define MCF_PSC2_IRSDR              (*(vuint8 *)(&__MBAR[0x00884C]))
#define MCF_PSC2_IRMDR              (*(vuint8 *)(&__MBAR[0x008850]))
#define MCF_PSC2_IRFDR              (*(vuint8 *)(&__MBAR[0x008854]))
#define MCF_PSC2_RFCNT              (*(vuint16*)(&__MBAR[0x008858]))
#define MCF_PSC2_TFCNT              (*(vuint16*)(&__MBAR[0x00885C]))
#define MCF_PSC2_RFSR               (*(vuint16*)(&__MBAR[0x008864]))
#define MCF_PSC2_TFSR               (*(vuint16*)(&__MBAR[0x008884]))
#define MCF_PSC2_RFCR               (*(vuint32*)(&__MBAR[0x008868]))
#define MCF_PSC2_TFCR               (*(vuint32*)(&__MBAR[0x008888]))
#define MCF_PSC2_RFAR               (*(vuint16*)(&__MBAR[0x00886E]))
#define MCF_PSC2_TFAR               (*(vuint16*)(&__MBAR[0x00888E]))
#define MCF_PSC2_RFRP               (*(vuint16*)(&__MBAR[0x008872]))
#define MCF_PSC2_TFRP               (*(vuint16*)(&__MBAR[0x008892]))
#define MCF_PSC2_RFWP               (*(vuint16*)(&__MBAR[0x008876]))
#define MCF_PSC2_TFWP               (*(vuint16*)(&__MBAR[0x008896]))
#define MCF_PSC2_RLRFP              (*(vuint16*)(&__MBAR[0x00887A]))
#define MCF_PSC2_TLRFP              (*(vuint16*)(&__MBAR[0x00889A]))
#define MCF_PSC2_RLWFP              (*(vuint16*)(&__MBAR[0x00887E]))
#define MCF_PSC2_TLWFP              (*(vuint16*)(&__MBAR[0x00889E]))
#define MCF_PSC3_MR                 (*(vuint8 *)(&__MBAR[0x008900]))
#define MCF_PSC3_SR                 (*(vuint16*)(&__MBAR[0x008904]))
#define MCF_PSC3_CSR                (*(vuint8 *)(&__MBAR[0x008904]))
#define MCF_PSC3_CR                 (*(vuint8 *)(&__MBAR[0x008908]))
#define MCF_PSC3_RB                 (*(vuint32*)(&__MBAR[0x00890C]))
#define MCF_PSC3_TB                 (*(vuint32*)(&__MBAR[0x00890C]))
#define MCF_PSC_TB3_8BIT            (*(vuint8 *)(&__MBAR[0x00890C]))
#define MCF_PSC_TB3_16BIT           (*(vuint16*)(&__MBAR[0x00890C]))
#define MCF_PSC_TB3_32BIT           (*(vuint32*)(&__MBAR[0x00890C]))
#define MCF_PSC_TB3_AC97            (*(vuint32*)(&__MBAR[0x00890C]))
#define MCF_PSC3_IPCR               (*(vuint8 *)(&__MBAR[0x008910]))
#define MCF_PSC3_ACR                (*(vuint8 *)(&__MBAR[0x008910]))
#define MCF_PSC3_ISR                (*(vuint16*)(&__MBAR[0x008914]))
#define MCF_PSC3_IMR                (*(vuint16*)(&__MBAR[0x008914]))
#define MCF_PSC3_CTUR               (*(vuint8 *)(&__MBAR[0x008918]))
#define MCF_PSC3_CTLR               (*(vuint8 *)(&__MBAR[0x00891C]))
#define MCF_PSC3_IP                 (*(vuint8 *)(&__MBAR[0x008934]))
#define MCF_PSC3_OPSET              (*(vuint8 *)(&__MBAR[0x008938]))
#define MCF_PSC3_OPRESET            (*(vuint8 *)(&__MBAR[0x00893C]))
#define MCF_PSC3_SICR               (*(vuint8 *)(&__MBAR[0x008940]))
#define MCF_PSC3_IRCR1              (*(vuint8 *)(&__MBAR[0x008944]))
#define MCF_PSC3_IRCR2              (*(vuint8 *)(&__MBAR[0x008948]))
#define MCF_PSC3_IRSDR              (*(vuint8 *)(&__MBAR[0x00894C]))
#define MCF_PSC3_IRMDR              (*(vuint8 *)(&__MBAR[0x008950]))
#define MCF_PSC3_IRFDR              (*(vuint8 *)(&__MBAR[0x008954]))
#define MCF_PSC3_RFCNT              (*(vuint16*)(&__MBAR[0x008958]))
#define MCF_PSC3_TFCNT              (*(vuint16*)(&__MBAR[0x00895C]))
#define MCF_PSC3_RFSR               (*(vuint16*)(&__MBAR[0x008964]))
#define MCF_PSC3_TFSR               (*(vuint16*)(&__MBAR[0x008984]))
#define MCF_PSC3_RFCR               (*(vuint32*)(&__MBAR[0x008968]))
#define MCF_PSC3_TFCR               (*(vuint32*)(&__MBAR[0x008988]))
#define MCF_PSC3_RFAR               (*(vuint16*)(&__MBAR[0x00896E]))
#define MCF_PSC3_TFAR               (*(vuint16*)(&__MBAR[0x00898E]))
#define MCF_PSC3_RFRP               (*(vuint16*)(&__MBAR[0x008972]))
#define MCF_PSC3_TFRP               (*(vuint16*)(&__MBAR[0x008992]))
#define MCF_PSC3_RFWP               (*(vuint16*)(&__MBAR[0x008976]))
#define MCF_PSC3_TFWP               (*(vuint16*)(&__MBAR[0x008996]))
#define MCF_PSC3_RLRFP              (*(vuint16*)(&__MBAR[0x00897A]))
#define MCF_PSC3_TLRFP              (*(vuint16*)(&__MBAR[0x00899A]))
#define MCF_PSC3_RLWFP              (*(vuint16*)(&__MBAR[0x00897E]))
#define MCF_PSC3_TLWFP              (*(vuint16*)(&__MBAR[0x00899E]))
#define MCF_PSC_MR(x)               (*(vuint8 *)(&__MBAR[0x008600+((x)*0x100)]))
#define MCF_PSC_SR(x)               (*(vuint16*)(&__MBAR[0x008604+((x)*0x100)]))
#define MCF_PSC_CSR(x)              (*(vuint8 *)(&__MBAR[0x008604+((x)*0x100)]))
#define MCF_PSC_CR(x)               (*(vuint8 *)(&__MBAR[0x008608+((x)*0x100)]))
#define MCF_PSC_RB(x)               (*(vuint32*)(&__MBAR[0x00860C+((x)*0x100)]))
#define MCF_PSC_TB(x)               (*(vuint32*)(&__MBAR[0x00860C+((x)*0x100)]))
#define MCF_PSC_TB_8BIT(x)          (*(vuint8 *)(&__MBAR[0x00860C+((x)*0x100)]))
#define MCF_PSC_TB_16BIT(x)         (*(vuint16*)(&__MBAR[0x00860C+((x)*0x100)]))
#define MCF_PSC_TB_32BIT(x)         (*(vuint32*)(&__MBAR[0x00860C+((x)*0x100)]))
#define MCF_PSC_TB_AC97(x)          (*(vuint32*)(&__MBAR[0x00860C+((x)*0x100)]))
#define MCF_PSC_IPCR(x)             (*(vuint8 *)(&__MBAR[0x008610+((x)*0x100)]))
#define MCF_PSC_ACR(x)              (*(vuint8 *)(&__MBAR[0x008610+((x)*0x100)]))
#define MCF_PSC_ISR(x)              (*(vuint16*)(&__MBAR[0x008614+((x)*0x100)]))
#define MCF_PSC_IMR(x)              (*(vuint16*)(&__MBAR[0x008614+((x)*0x100)]))
#define MCF_PSC_CTUR(x)             (*(vuint8 *)(&__MBAR[0x008618+((x)*0x100)]))
#define MCF_PSC_CTLR(x)             (*(vuint8 *)(&__MBAR[0x00861C+((x)*0x100)]))
#define MCF_PSC_IP(x)               (*(vuint8 *)(&__MBAR[0x008634+((x)*0x100)]))
#define MCF_PSC_OPSET(x)            (*(vuint8 *)(&__MBAR[0x008638+((x)*0x100)]))
#define MCF_PSC_OPRESET(x)          (*(vuint8 *)(&__MBAR[0x00863C+((x)*0x100)]))
#define MCF_PSC_SICR(x)             (*(vuint8 *)(&__MBAR[0x008640+((x)*0x100)]))
#define MCF_PSC_IRCR1(x)            (*(vuint8 *)(&__MBAR[0x008644+((x)*0x100)]))
#define MCF_PSC_IRCR2(x)            (*(vuint8 *)(&__MBAR[0x008648+((x)*0x100)]))
#define MCF_PSC_IRSDR(x)            (*(vuint8 *)(&__MBAR[0x00864C+((x)*0x100)]))
#define MCF_PSC_IRMDR(x)            (*(vuint8 *)(&__MBAR[0x008650+((x)*0x100)]))
#define MCF_PSC_IRFDR(x)            (*(vuint8 *)(&__MBAR[0x008654+((x)*0x100)]))
#define MCF_PSC_RFCNT(x)            (*(vuint16*)(&__MBAR[0x008658+((x)*0x100)]))
#define MCF_PSC_TFCNT(x)            (*(vuint16*)(&__MBAR[0x00865C+((x)*0x100)]))
#define MCF_PSC_RFSR(x)             (*(vuint16*)(&__MBAR[0x008664+((x)*0x100)]))
#define MCF_PSC_TFSR(x)             (*(vuint16*)(&__MBAR[0x008684+((x)*0x100)]))
#define MCF_PSC_RFCR(x)             (*(vuint32*)(&__MBAR[0x008668+((x)*0x100)]))
#define MCF_PSC_TFCR(x)             (*(vuint32*)(&__MBAR[0x008688+((x)*0x100)]))
#define MCF_PSC_RFAR(x)             (*(vuint16*)(&__MBAR[0x00866E+((x)*0x100)]))
#define MCF_PSC_TFAR(x)             (*(vuint16*)(&__MBAR[0x00868E+((x)*0x100)]))
#define MCF_PSC_RFRP(x)             (*(vuint16*)(&__MBAR[0x008672+((x)*0x100)]))
#define MCF_PSC_TFRP(x)             (*(vuint16*)(&__MBAR[0x008692+((x)*0x100)]))
#define MCF_PSC_RFWP(x)             (*(vuint16*)(&__MBAR[0x008676+((x)*0x100)]))
#define MCF_PSC_TFWP(x)             (*(vuint16*)(&__MBAR[0x008696+((x)*0x100)]))
#define MCF_PSC_RLRFP(x)            (*(vuint16*)(&__MBAR[0x00867A+((x)*0x100)]))
#define MCF_PSC_TLRFP(x)            (*(vuint16*)(&__MBAR[0x00869A+((x)*0x100)]))
#define MCF_PSC_RLWFP(x)            (*(vuint16*)(&__MBAR[0x00867E+((x)*0x100)]))
#define MCF_PSC_TLWFP(x)            (*(vuint16*)(&__MBAR[0x00869E+((x)*0x100)]))

/* Bit definitions and macros for MCF_PSC_MR */
#define MCF_PSC_MR_BC(x)            (((x)&0x03)<<0)
#define MCF_PSC_MR_PT               (0x04)
#define MCF_PSC_MR_PM(x)            (((x)&0x03)<<3)
#define MCF_PSC_MR_ERR              (0x20)
#define MCF_PSC_MR_RXIRQ            (0x40)
#define MCF_PSC_MR_RXRTS            (0x80)
#define MCF_PSC_MR_SB(x)            (((x)&0x0F)<<0)
#define MCF_PSC_MR_TXCTS            (0x10)
#define MCF_PSC_MR_TXRTS            (0x20)
#define MCF_PSC_MR_CM(x)            (((x)&0x03)<<6)
#define MCF_PSC_MR_PM_MULTI_ADDR    (0x1C)
#define MCF_PSC_MR_PM_MULTI_DATA    (0x18)
#define MCF_PSC_MR_PM_NONE          (0x10)
#define MCF_PSC_MR_PM_FORCE_HI      (0x0C)
#define MCF_PSC_MR_PM_FORCE_LO      (0x08)
#define MCF_PSC_MR_PM_ODD           (0x04)
#define MCF_PSC_MR_PM_EVEN          (0x00)
#define MCF_PSC_MR_BC_5             (0x00)
#define MCF_PSC_MR_BC_6             (0x01)
#define MCF_PSC_MR_BC_7             (0x02)
#define MCF_PSC_MR_BC_8             (0x03)
#define MCF_PSC_MR_CM_NORMAL        (0x00)
#define MCF_PSC_MR_CM_ECHO          (0x40)
#define MCF_PSC_MR_CM_LOCAL_LOOP    (0x80)
#define MCF_PSC_MR_CM_REMOTE_LOOP   (0xC0)
#define MCF_PSC_MR_SB_STOP_BITS_1   (0x07)
#define MCF_PSC_MR_SB_STOP_BITS_15  (0x08)
#define MCF_PSC_MR_SB_STOP_BITS_2   (0x0F)

/* Bit definitions and macros for MCF_PSC_SR */
#define MCF_PSC_SR_ERR              (0x0040)
#define MCF_PSC_SR_CDE_DEOF         (0x0080)
#define MCF_PSC_SR_RXRDY            (0x0100)
#define MCF_PSC_SR_FU               (0x0200)
#define MCF_PSC_SR_TXRDY            (0x0400)
#define MCF_PSC_SR_TXEMP_URERR      (0x0800)
#define MCF_PSC_SR_OE               (0x1000)
#define MCF_PSC_SR_PE_CRCERR        (0x2000)
#define MCF_PSC_SR_FE_PHYERR        (0x4000)
#define MCF_PSC_SR_RB_NEOF          (0x8000)

/* Bit definitions and macros for MCF_PSC_CSR */
#define MCF_PSC_CSR_TCSEL(x)        (((x)&0x0F)<<0)
#define MCF_PSC_CSR_RCSEL(x)        (((x)&0x0F)<<4)
#define MCF_PSC_CSR_RCSEL_SYS_CLK   (0xD0)
#define MCF_PSC_CSR_RCSEL_CTM16     (0xE0)
#define MCF_PSC_CSR_RCSEL_CTM       (0xF0)
#define MCF_PSC_CSR_TCSEL_SYS_CLK   (0x0D)
#define MCF_PSC_CSR_TCSEL_CTM16     (0x0E)
#define MCF_PSC_CSR_TCSEL_CTM       (0x0F)

/* Bit definitions and macros for MCF_PSC_CR */
#define MCF_PSC_CR_RXC(x)           (((x)&0x03)<<0)
#define MCF_PSC_CR_TXC(x)           (((x)&0x03)<<2)
#define MCF_PSC_CR_MISC(x)          (((x)&0x07)<<4)
#define MCF_PSC_CR_NONE             (0x00)
#define MCF_PSC_CR_STOP_BREAK       (0x70)
#define MCF_PSC_CR_START_BREAK      (0x60)
#define MCF_PSC_CR_BKCHGINT         (0x50)
#define MCF_PSC_CR_RESET_ERROR      (0x40)
#define MCF_PSC_CR_RESET_TX         (0x30)
#define MCF_PSC_CR_RESET_RX         (0x20)
#define MCF_PSC_CR_RESET_MR         (0x10)
#define MCF_PSC_CR_TX_DISABLED      (0x08)
#define MCF_PSC_CR_TX_ENABLED       (0x04)
#define MCF_PSC_CR_RX_DISABLED      (0x02)
#define MCF_PSC_CR_RX_ENABLED       (0x01)

/* Bit definitions and macros for MCF_PSC_TB_AC97 */
#define MCF_PSC_TB_AC97_SOF         (0x00000800)
#define MCF_PSC_TB_AC97_TB(x)       (((x)&0x000FFFFF)<<12)

/* Bit definitions and macros for MCF_PSC_IPCR */
#define MCF_PSC_IPCR_RESERVED       (0x0C)
#define MCF_PSC_IPCR_CTS            (0x0D)
#define MCF_PSC_IPCR_D_CTS          (0x1C)
#define MCF_PSC_IPCR_SYNC           (0x8C)

/* Bit definitions and macros for MCF_PSC_ACR */
#define MCF_PSC_ACR_IEC0            (0x01)
#define MCF_PSC_ACR_CTMS(x)         (((x)&0x07)<<4)
#define MCF_PSC_ACR_BRG             (0x80)

/* Bit definitions and macros for MCF_PSC_ISR */
#define MCF_PSC_ISR_ERR             (0x0040)
#define MCF_PSC_ISR_DEOF            (0x0080)
#define MCF_PSC_ISR_TXRDY           (0x0100)
#define MCF_PSC_ISR_RXRDY_FU        (0x0200)
#define MCF_PSC_ISR_DB              (0x0400)
#define MCF_PSC_ISR_IPC             (0x8000)

/* Bit definitions and macros for MCF_PSC_IMR */
#define MCF_PSC_IMR_ERR             (0x0040)
#define MCF_PSC_IMR_DEOF            (0x0080)
#define MCF_PSC_IMR_TXRDY           (0x0100)
#define MCF_PSC_IMR_RXRDY_FU        (0x0200)
#define MCF_PSC_IMR_DB              (0x0400)
#define MCF_PSC_IMR_IPC             (0x8000)

/* Bit definitions and macros for MCF_PSC_CTUR */
#define MCF_PSC_CTUR_CT(x)          (((x)&0xFF)<<0)

/* Bit definitions and macros for MCF_PSC_CTLR */
#define MCF_PSC_CTLR_CT(x)          (((x)&0xFF)<<0)

/* Bit definitions and macros for MCF_PSC_IP */
#define MCF_PSC_IP_CTS              (0x01)
#define MCF_PSC_IP_TGL              (0x40)
#define MCF_PSC_IP_LWPR_B           (0x80)

/* Bit definitions and macros for MCF_PSC_OPSET */
#define MCF_PSC_OPSET_RTS           (0x01)

/* Bit definitions and macros for MCF_PSC_OPRESET */
#define MCF_PSC_OPRESET_RTS         (0x01)

/* Bit definitions and macros for MCF_PSC_SICR */
#define MCF_PSC_SICR_SIM(x)         (((x)&0x07)<<0)
#define MCF_PSC_SICR_SHDIR          (0x10)
#define MCF_PSC_SICR_DTS            (0x20)
#define MCF_PSC_SICR_AWR            (0x40)
#define MCF_PSC_SICR_ACRB           (0x80)
#define MCF_PSC_SICR_SIM_UART       (0x00)
#define MCF_PSC_SICR_SIM_MODEM8     (0x01)
#define MCF_PSC_SICR_SIM_MODEM16    (0x02)
#define MCF_PSC_SICR_SIM_AC97       (0x03)
#define MCF_PSC_SICR_SIM_SIR        (0x04)
#define MCF_PSC_SICR_SIM_MIR        (0x05)
#define MCF_PSC_SICR_SIM_FIR        (0x06)

/* Bit definitions and macros for MCF_PSC_IRCR1 */
#define MCF_PSC_IRCR1_SPUL          (0x01)
#define MCF_PSC_IRCR1_SIPEN         (0x02)
#define MCF_PSC_IRCR1_FD            (0x04)

/* Bit definitions and macros for MCF_PSC_IRCR2 */
#define MCF_PSC_IRCR2_NXTEOF        (0x01)
#define MCF_PSC_IRCR2_ABORT         (0x02)
#define MCF_PSC_IRCR2_SIPREQ        (0x04)

/* Bit definitions and macros for MCF_PSC_IRSDR */
#define MCF_PSC_IRSDR_IRSTIM(x)     (((x)&0xFF)<<0)

/* Bit definitions and macros for MCF_PSC_IRMDR */
#define MCF_PSC_IRMDR_M_FDIV(x)     (((x)&0x7F)<<0)
#define MCF_PSC_IRMDR_FREQ          (0x80)

/* Bit definitions and macros for MCF_PSC_IRFDR */
#define MCF_PSC_IRFDR_F_FDIV(x)     (((x)&0x0F)<<0)

/* Bit definitions and macros for MCF_PSC_RFCNT */
#define MCF_PSC_RFCNT_CNT(x)        (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_TFCNT */
#define MCF_PSC_TFCNT_CNT(x)        (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_RFSR */
#define MCF_PSC_RFSR_EMT            (0x0001)
#define MCF_PSC_RFSR_ALARM          (0x0002)
#define MCF_PSC_RFSR_FU             (0x0004)
#define MCF_PSC_RFSR_FRMRY          (0x0008)
#define MCF_PSC_RFSR_OF             (0x0010)
#define MCF_PSC_RFSR_UF             (0x0020)
#define MCF_PSC_RFSR_RXW            (0x0040)
#define MCF_PSC_RFSR_FAE            (0x0080)
#define MCF_PSC_RFSR_FRM(x)         (((x)&0x000F)<<8)
#define MCF_PSC_RFSR_TAG            (0x1000)
#define MCF_PSC_RFSR_TXW            (0x4000)
#define MCF_PSC_RFSR_IP             (0x8000)
#define MCF_PSC_RFSR_FRM_BYTE0      (0x0800)
#define MCF_PSC_RFSR_FRM_BYTE1      (0x0400)
#define MCF_PSC_RFSR_FRM_BYTE2      (0x0200)
#define MCF_PSC_RFSR_FRM_BYTE3      (0x0100)

/* Bit definitions and macros for MCF_PSC_TFSR */
#define MCF_PSC_TFSR_EMT            (0x0001)
#define MCF_PSC_TFSR_ALARM          (0x0002)
#define MCF_PSC_TFSR_FU             (0x0004)
#define MCF_PSC_TFSR_FRMRY          (0x0008)
#define MCF_PSC_TFSR_OF             (0x0010)
#define MCF_PSC_TFSR_UF             (0x0020)
#define MCF_PSC_TFSR_RXW            (0x0040)
#define MCF_PSC_TFSR_FAE            (0x0080)
#define MCF_PSC_TFSR_FRM(x)         (((x)&0x000F)<<8)
#define MCF_PSC_TFSR_TAG            (0x1000)
#define MCF_PSC_TFSR_TXW            (0x4000)
#define MCF_PSC_TFSR_IP             (0x8000)
#define MCF_PSC_TFSR_FRM_BYTE0      (0x0800)
#define MCF_PSC_TFSR_FRM_BYTE1      (0x0400)
#define MCF_PSC_TFSR_FRM_BYTE2      (0x0200)
#define MCF_PSC_TFSR_FRM_BYTE3      (0x0100)

/* Bit definitions and macros for MCF_PSC_RFCR */
#define MCF_PSC_RFCR_CNTR(x)        (((x)&0x0000FFFF)<<0)
#define MCF_PSC_RFCR_TXW_MSK        (0x00040000)
#define MCF_PSC_RFCR_OF_MSK         (0x00080000)
#define MCF_PSC_RFCR_UF_MSK         (0x00100000)
#define MCF_PSC_RFCR_RXW_MSK        (0x00200000)
#define MCF_PSC_RFCR_FAE_MSK        (0x00400000)
#define MCF_PSC_RFCR_IP_MSK         (0x00800000)
#define MCF_PSC_RFCR_GR(x)          (((x)&0x00000007)<<24)
#define MCF_PSC_RFCR_FRMEN          (0x08000000)
#define MCF_PSC_RFCR_TIMER          (0x10000000)
#define MCF_PSC_RFCR_WRITETAG       (0x20000000)
#define MCF_PSC_RFCR_SHADOW         (0x80000000)

/* Bit definitions and macros for MCF_PSC_TFCR */
#define MCF_PSC_TFCR_CNTR(x)        (((x)&0x0000FFFF)<<0)
#define MCF_PSC_TFCR_TXW_MSK        (0x00040000)
#define MCF_PSC_TFCR_OF_MSK         (0x00080000)
#define MCF_PSC_TFCR_UF_MSK         (0x00100000)
#define MCF_PSC_TFCR_RXW_MSK        (0x00200000)
#define MCF_PSC_TFCR_FAE_MSK        (0x00400000)
#define MCF_PSC_TFCR_IP_MSK         (0x00800000)
#define MCF_PSC_TFCR_GR(x)          (((x)&0x00000007)<<24)
#define MCF_PSC_TFCR_FRMEN          (0x08000000)
#define MCF_PSC_TFCR_TIMER          (0x10000000)
#define MCF_PSC_TFCR_WRITETAG       (0x20000000)
#define MCF_PSC_TFCR_SHADOW         (0x80000000)

/* Bit definitions and macros for MCF_PSC_RFAR */
#define MCF_PSC_RFAR_ALARM(x)       (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_TFAR */
#define MCF_PSC_TFAR_ALARM(x)       (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_RFRP */
#define MCF_PSC_RFRP_READ(x)        (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_TFRP */
#define MCF_PSC_TFRP_READ(x)        (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_RFWP */
#define MCF_PSC_RFWP_WRITE(x)       (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_TFWP */
#define MCF_PSC_TFWP_WRITE(x)       (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_RLRFP */
#define MCF_PSC_RLRFP_LFP(x)        (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_TLRFP */
#define MCF_PSC_TLRFP_LFP(x)        (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_RLWFP */
#define MCF_PSC_RLWFP_LFP(x)        (((x)&0x01FF)<<0)

/* Bit definitions and macros for MCF_PSC_TLWFP */
#define MCF_PSC_TLWFP_LFP(x)        (((x)&0x01FF)<<0)

/********************************************************************/

#endif /* __MCF548X_PSC_H__ */
