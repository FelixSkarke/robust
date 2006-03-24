C File: GamRob.f
C Matias Salibian
C 21/03/00
C 12/04/00

C
C==========================================================================
C
      DOUBLE PRECISION FUNCTION S_UZANS(DX,WGT,N,EXU,EXGAM,
     1 		alfa,sigm,a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
	  implicit double precision (a-h, o-z)
      DIMENSION WGT(N),yb(8,2)
      EXTERNAL EXGAM,EXU
      DATA NCALL,XLGMN,YLGMN/0,0.D0,0.D0/

C to avoid warnings when compiling
	  dummy = digam
	  dummy = yb(1,1)
	  dummy = sigm
C
C  Initializations
C
      IF (NCALL.EQ.0) THEN
        NCALL=1
        CALL S_MACHD(4,XLGMN)
        CALL S_MACHD(5,YLGMN)
      ENDIF
      S=DBLE(DX)
      BB1=DBLE(B1)
      BB2=DBLE(B2)
      ALOGS=YLGMN
      IF(S.GT.XLGMN)ALOGS=DLOG(S)
      ANS=EXGAM(1.D0,ALFA,S)
      S_UZANS=0.D0
      IF (ANS.EQ.0.D0) RETURN
      X1=DBLE(S-C1)
      Z1=DBLE(A11)*X1
      U1=1.D0
      TMP=DABS(Z1)
      IF (TMP.GT.BB1) U1=BB1/TMP
      IF (WGT(1).EQ.4.D0) GOTO 40
      X2=DBLE(ALOGS-C2)
      Z2=DBLE(A22)*X2+DBLE(A21)*X1
      U2=1.D0
      TMP=DABS(Z2)
      IF (TMP.GT.BB2) U2=BB2/TMP
      I=int(WGT(1))
      GOTO (10,20,30) I
   10 S_UZANS=U1*U2*X1*X2*DBLE(ANS)
      RETURN
   20 S_UZANS=U1*U2*X1*X1*DBLE(ANS)
      RETURN
   30 S_UZANS=(U2*(DBLE(BETA)*X1+X2))**2*DBLE(ANS)
      RETURN
   40 S_UZANS=(U1*X1)**2*DBLE(ANS)
      RETURN
      END
C
C========================================================================
C
      SUBROUTINE S_INTUXG(X,NREP,IOPT,TIL,SUM,XLOWER,UPPER,
     1 	alfa,sigm,a11,a21,a22,b1,b2,c1,c2,yb,digam,BETA)
	  implicit double precision (a-h, o-z)
      DOUBLE PRECISION S_UZANS,TILD,ERRSTD,WORK,S_EXU,LO,HI,SS(7)
      dimension WGT(1),X(NREP),IWORK(80),WORK(320),yb(8,2)
      EXTERNAL S_EXU,S_UZANS,S_GAMMA
C
C     INITIALISATION
C
      LIMIT=80
      KEY=1
C
      WGT(1)=DBLE(IOPT)
      HI=XLOWER
      X(NREP)=UPPER
      SUM=0.D0
      I=0
  100 I=I+1
      LO=HI
      IF (I.GT.NREP) GOTO 200
      HI=DMIN1(X(I),UPPER)
      IF (LO.GE.HI) THEN
        SS(I)=0.D0
        GOTO 100
      ENDIF
      TILD=TIL
      if (hi.le.1.d-3.and.iopt.eq.3) tild=1.d-1 

      CALL S_INTGRD(S_UZANS,WGT,1,s_EXU,s_GAMMA,LO,HI,TILD,TILD,
     1            KEY,LIMIT,SS(I),ERRSTD,NEVAL,IER,WORK,IWORK,
     *			 alfa,sigm,
     2			 a11,a21,a22,b1,b2,c1,c2,YB,DIGAM,beta)

      SUM=SUM+SS(I)
      IF (dabs(HI-UPPER).LT.1.D-6) GOTO 200
      GOTO 100
  200 RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_IEQTA1(AA,FA,A11,C1,B1,XLOWER,XUPPER,TIL,
     1		alfa,sigm,a21,a22,b2,c2,yb,digam,beta)
	  implicit double precision (a-h, o-z)
	  double precision mypar
      DIMENSION X(3),yb(8,2),mypar(18)
C
      XL=-B1/A11+C1
      IF (XL.LT.0.D0) XL=0.D0
      XU=B1/A11+C1
      IF (XL.GT.XU) THEN
        TMP=XL
        XL=XU
        XU=TMP
      ENDIF
      AA=0.D0
      X(1)=XL
      X(2)=XU
	
      mypar(1)=XL
      mypar(2)=xu
      mypar(3)=til
      mypar(4)=sum1
      mypar(5)=xlower
      mypar(6)=xupper
      mypar(7)=alfa
      mypar(8)=sigm
      mypar(9)=a11
      mypar(10)=a21
      mypar(11)=a22
      mypar(12)=b1
      mypar(13)=b2
      mypar(14)=c1
      mypar(15)=c2
      mypar(16)=digam
      mypar(17)=beta
      mypar(18)=yb(1,1)

      CALL S_INTUXG(X,3,4,TIL,SUM1,XLOWER,XUPPER,alfa,sigm,
     *	a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
      AA=1.D0/dsqrt(SUM1)
      FA=A11*A11*SUM1-1.D0
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_IEQTA2(AA,Fa,A11,C1,B1,XLOWER,XUPPER,TIL,alfa,
     *		sigm,a21,a22,b2,c2,yb,digam,x2,nsol,beta)
      implicit double precision(a-h, o-z)
      DIMENSION X(7),Z0(7),X2(4)
      DATA Z0/7*0.D0/
C
      DO 10 I=1,NSOL
      X(I)=X2(I)
   10 CONTINUE
      X11=-B1/A11+C1
      IF (X11.LT.0.) X11=0.D0
      X12= B1/A11+C1
      IF (X11.GT.X12) THEN
        TMP=X11
        X11=X12
        X12=TMP
      ENDIF
      X(NSOL+1)=X11
      X(NSOL+2)=X12
      N2=NSOL+2
      CALL S_SRT2(X,Z0,7,1,N2)
      IOPT=1
   50 CALL S_INTUXG(X,N2+1,IOPT,TIL,SUMI,XLOWER,XUPPER,alfa,
     1	sigm,a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
      IF (IOPT.EQ.1) THEN
        u12x12=SUMI
        IOPT=2
        GOTO 50
      ENDIF
      digam=SUMI
      IF (digam .LT. 1.D-6) digam=1.D-6
      BETA=-u12x12/digam
      CALL S_SRT2(X2,Z0,NSOL,1,NSOL)   
      DO 150 I=1,NSOL
  150 X(I)=X2(I)
      CALL S_INTUXG(X,NSOL+1,3,TIL,SUM,XLOWER,XUPPER,alfa,
     1	sigm,a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
      AA=1.D0/DSQRT(SUM)
      FA=A22*A22*SUM - 1.D0
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_IEQTA3(AA,FA,A11,A21,A22,U12X11,BETA)
c
c argument u12x11 is also called digam (part of /GAMPR/)
c argument beta is also called trigm (part of /GAMPR/)
c
      implicit double precision (a-h, o-z)
      AA=BETA*AA
      FA=A11*U12X11*(A21-A22*BETA)
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_A2A3A1(MAXIT,TOL,ALPHA,A,FA,NIT,A11,A21,A22,
     1 C1,C2,B1,B2,XLOWER,XUPPER,U12X11,BETA,X2,Y2,NSOL,TIL,sigm,yb)
C     * digam)
      implicit double precision (a-h, o-z)
      double precision mypar
      dimension A(3),FA(3),X2(4),Y2(0:4),yb(8,2),mypar(12)
C
C  STEP 0 : INITIALIZATION
C  ------
      NIT=1
      TOL2=TOL*TOL
      A11=A(1)
      A21=A(2)
      A22=A(3)
      ALFA=ALPHA
      SIGM=1.D0
C
C  STEP 1: Compute new value of (Aij) and check convergence
C  ------
  100 continue
      CALL S_SOLVX(B2,TOL,NSOL,X2,Y2,A21,A22,C1,C2)
	  mypar(1) = a11
	  mypar(2) = a21
	  mypar(3) = a22
	  mypar(4) = b1
	  mypar(5) = b2
	  mypar(6) = c1
	  mypar(7) = c2
	  mypar(8) = alfa
	  mypar(9) = sigm
	  mypar(10) = u12x11
	  mypar(11) = dble(nsol)
	  mypar(12) = beta

      CALL S_IEQTA1(a1,FA(1),A11,C1,B1,XLOWER,XUPPER,TIL,alfa,
     *		sigm,a21,a22,b2,c2,yb,U12X11,beta)
	  mypar(1) = a11
	  mypar(2) = a21
	  mypar(3) = a22
	  mypar(4) = b1
	  mypar(5) = b2
	  mypar(6) = c1
	  mypar(7) = c2
	  mypar(8) = alfa
	  mypar(9) = sigm
	  mypar(10) = u12x11
	  mypar(11) = dble(nsol)
	  mypar(12) = a1

      CALL S_IEQTA2(a2,FA(2),A11,C1,B1,XLOWER,XUPPER,TIL,alfa,
     *		sigm,a21,a22,b2,c2,yb,U12X11,x2,nsol,beta)
	  mypar(1) = a11
	  mypar(2) = a21
	  mypar(3) = a22
	  mypar(4) = b1
	  mypar(5) = b2
	  mypar(6) = c1
	  mypar(7) = c2
	  mypar(8) = alfa
	  mypar(9) = sigm
	  mypar(10) = u12x11
	  mypar(11) = dble(nsol)
	  mypar(12) = a2

      a3=a2
      CALL S_IEQTA3(a3,FA(3),A11,A21,A22,U12X11,BETA)
	  mypar(1) = a11
	  mypar(2) = a21
	  mypar(3) = a22
	  mypar(4) = b1
	  mypar(5) = b2
	  mypar(6) = c1
	  mypar(7) = c2
	  mypar(8) = alfa
	  mypar(9) = sigm
	  mypar(10) = u12x11
	  mypar(11) = dble(nsol)
	  mypar(12) = a3

      S=(fa(3))**2+(fa(2))**2+(fa(1))**2
      A11=a1
      A21=a3
      A22=a2
c
c here's the problem with a21 and a22
c
      IF (S.LT.TOL2) GOTO 200
      if(nit.ge.maxit)goto 200
      nit=nit+1
      goto 100
C
C  STEP 2: EXIT
C  ------
  200 A(1)=A11
      A(2)=A21
      A(3)=A22
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_CRETABI(B1,B2,KK,LA,A,MAXTA,MAXTC,MAXIT,TIL,TOL,
     +           ALPHA1,ALPHA2,MONIT,TAB,TPAR)
	  implicit double precision (a-h, o-z)
      dimension A(3),FA(3),CALF(2),ZERO(2),TAB(kk,5),ver(7),tpar(6)
	  dimension x2(4),y2(0:4),yb(8,2)
      EXTERNAL S_GAMDIGAMA,S_GAMTRIGAM

      PB1=B1
      PB2=B2
      FA(1)=0.D0
      FA(2)=0.D0
      FA(3)=0.D0
      SIGM=1.D0
      TL=TIL
      delta=0.D0
      if (kk.GT.1) delta=(ALPHA2-ALPHA1)/(dble(KK) - 1.D0)
      tpar(1)=B1
      tpar(2)=B2
      tpar(3)=alpha1
      tpar(4)=alpha2
      tpar(5)=dble(kk)
      tpar(6)=delta
      if (la.le.1) then
        a11=1.D0
        a21=0.D0
        a22=1.D0
        a(1)=1.D0
        a(3)=1.D0
        if (maxtc.eq.1) maxtc=20
      endif
      suma=dabs(a(1))+dabs(a(2))+dabs(a(3))
      DO 100 IA=1,KK
      ALFA=tpar(3)+(dble(IA) - 1.D0 )*tpar(6)
      DIGAM=S_GAMDIGAMA(ALFA)
      trigm=s_GAMtrigam(alfa)
      if (la.eq.2.or.suma.eq.0.D0) then
         A22=1.D0/dsqrt(trigm - 1.D0/alfa)
         A21=-a22/ALFA
         A11= 1.D0/dsqrt(alfa)
      endif
      if (la.le.2) then
        c2=digam
        c1=alfa
      elseif (ia.eq.1) then
        if (suma.ne.0.D0) then
          A11=A(1)
          A21=A(2)
          A22=A(3)
        endif
        c2=digam
        c1=alfa
      endif
      CALL S_LIMGAM(1.D0,ALFA,XLOWER,UPPER)
      CALL S_SOLVX(B2,TOL,NSOL,X2,Y2,A21,A22,C1,C2)
      CALF(1)=c1
      CALF(2)=c2
      A(1)=A11
      A(2)=A21
      A(3)=A22
      NIT=1
   10 continue
      IF (LA.GE.2) CALL S_A2A3A1(MAXTA,TOL,ALFA,A,FA,NITA,
     1 A11,A21,A22,C1,C2,B1,B2,XLOWER,UPPER,DIGAM,TRIGM,
     2 X2,Y2,NSOL,TIL,sigm,yb)
      CALL S_SOLC12(MAXTC,TOL,ALFA,CALF,ZERO,NITC,X2,
     1 Y2,NSOL,A11,A21,A22,C1,C2,B1,B2)

      CALL S_SOLVX(B2,TOL,NSOL,X2,Y2,A21,A22,C1,C2)

      IF (LA.LE.1) GOTO 15
      CALL S_IEQTA1(aa,FA1,A11,C1,B1,XLOWER,UPPER,TIL,alfa,
     *		sigm,a21,a22,b2,c2,yb,digam,trigm)

      IF (DABS(FA1).GT.TOL.AND.NIT.NE.MAXIT) GOTO 20
      CALL S_IEQTA2(aa,FA2,A11,C1,B1,XLOWER,UPPER,TIL,alfa,
     *		sigm,a21,a22,b2,c2,yb,digam,x2,nsol,trigm)
      IF (DABS(FA2).GT.TOL.AND.NIT.NE.MAXIT) GOTO 20
      CALL S_IEQTA3(aa,FA3,A11,A21,A22,DIGAM,TRIGM)
      IF (DABS(FA3).GT.TOL.AND.NIT.NE.MAXIT) GOTO 20
   15 CONTINUE
      CALL S_EQTNC1(FC1,F1A,F1B,B1,A11,C1,ALFA)
      IF (DABS(FC1).GT.TOL.AND.NIT.NE.MAXIT) GOTO 20
      CALL S_EQTNC2(FC2,F2A,F2B,B2,A21,A22,C1,C2,X2,Y2,NSOL,
     1					ALFA)
      IF (DABS(FC2).GT.TOL) GOTO 20
      GOTO 30
   20 IF (NIT.eq.MAXIT) GOTO 30
      NIT=NIT+1
      GOTO 10
   30 CONTINUE
      tab(ia,1)=calf(1)
      tab(ia,2)=calf(2)
      tab(ia,3)=a(1)
      tab(ia,4)=a(2)
      tab(ia,5)=a(3)
      if (monit.eq.0) goto 100
      if (mod(ia,monit).eq.0) then
        ver(1)=alfa
        ver(2)=dble(nit)
        ver(3)=fc1
        ver(4)=fc2
        ver(5)=fa1
        ver(6)=fa2
        ver(7)=fa3
        ver(1)=dble(nsol)
        ver(2)=x2(1)
        ver(3)=x2(2)
        ver(4)=x2(3)
        ver(5)=x2(4)
      endif
      if (delta.eq.0.D0) RETURN 
 100  CONTINUE
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_SOLVX(B,TOL,NSOL,XB,YB,A21,A22,C1,C2)
C
C  Solutions of y=a22*(ln(x)-c2)+a21*(x-c1)=+/-B, a22<>0
C
      implicit double precision (a-h, o-z)
      DIMENSION XB(4),YB(0:4)
      EXTERNAL S_XEXPD
      BS=B
      do 50 j=1,4
      xb(j)=0.D0
  50  continue
      IF (A22.LT.0.D0) BS=-B
      IF (A21.EQ.0.D0) THEN
        YB(0)=-BS
        XB(1)=S_XEXPD(-BS/A22+C2)
        YB(1)=0.D0
        XB(2)=S_XEXPD(BS/A22+C2)
        YB(2)=BS
        NSOL=2
        RETURN
      ENDIF
      X0=-A22/A21
      IF (X0.LT.0.D0) THEN
        YB(0)=-BS
        XB(1)=1.D0
C
C (**) here x0 < 0
C what does solvx0 do then???
C
        CALL S_SOLVX0(-BS,TOL,x0,1,XB(1),A21,A22,C1,C2)
        YB(1)=0.D0
        XB(2)=1.D0
        CALL S_SOLVX0( BS,TOL,x0,2,XB(2),A21,A22,C1,C2)
        YB(1)=0.D0
        YB(2)=BS
        NSOL=2
      ELSE
        Y0=A22*(DLOG(X0)-C2)+A21*(X0-C1)
        IF ((A22.GT.0.D0.AND.Y0.GT.B).OR.
     1 (A22.LT.0.D0.AND.Y0.LT.-B)) THEN
          YB(0)=-BS
          CALL S_SOLVX0(-BS,TOL,x0,1,XB(1),A21,A22,C1,C2)
          YB(1)=0.D0
          CALL S_SOLVX0(-BS,TOL,x0,2,XB(4),A21,A22,C1,C2)
          YB(4)=-BS
          YB(2)=BS
          CALL S_SOLVX0(BS,TOL,x0,1,XB(2),A21,A22,C1,C2)
          CALL S_SOLVX0(BS,TOL,x0,2,XB(3),A21,A22,C1,C2)
          YB(3)=0.D0
          NSOL=4
       ELSEIF ((A22.GT.0..AND.Y0.GT.-B).OR.(A22.LT.0..AND.Y0.LT.B)) THEN
          YB(0)=-BS
          CALL S_SOLVX0(-BS,TOL,x0,1,XB(1),A21,A22,C1,C2)
          YB(1)=0.D0
          CALL S_SOLVX0(-BS,TOL,x0,2,XB(2),A21,A22,C1,C2)
          YB(2)=-BS
          NSOL=2
        ELSE
          XB(1)=0.D0
          YB(0)=-BS
          NSOL=0
        ENDIF
      ENDIF
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_SOLVX0(B,TOL,x0,istep,X,A21,A22,C1,C2)
      implicit double precision (a-h, o-z)
      DATA NCALL,XLGMN,YLGMN/0,0.D0,0.D0/
C
C  Initializations
C
      IF (NCALL.EQ.0) THEN
        NCALL=1
        CALL S_MACHD(4,XLGMN)
        CALL S_MACHD(5,YLGMN)
      ENDIF
      Y=B+A22*C2+A21*C1
      if(istep.eq.1)then
C
C  1 solution plus petite que x0
C
C
C  what happens when x0 < 0 ?? 
C  xmin = 0 
C  xmax < xmin ??
C
C  but this situation seems accepted as the 
C  call to solvx0 in (**) allows it... ???
C
      Xmin=0.D0
      xmax=X0
  100 x=xmin+(xmax-xmin)/2.D0
      if(xmax-xmin.lt.tol)return
      ALOGX=YLGMN
      IF (X.GT.XLGMN) ALOGX=DLOG(X)
      F=A22*ALOGX+A21*X-Y
      if(f.gt.0.D0)then
        xmax=x
        goto 100
      elseif(f.lt.0.D0)then
        xmin=x
        goto 100
      elseif(f.eq.0.D0)then
      return
      endif
      endif
      if(istep.eq.2)then
C
C  1 solution plus grande que x0
C
      Xmin=x0
      xmax=2.D0*x0
 200  ALOGX=YLGMN
      IF (Xmax.GT.XLGMN) then
	  	ALOGX=DLOG(Xmax)
	  endif
      F=A22*ALOGX+A21*Xmax-Y
      if(f.gt.0.D0)then
      xmax=2.D0*xmax
      goto 200
      endif
  300 x=xmin+(xmax-xmin)/2.D0
      if(xmax-xmin.lt.tol)return
      ALOGX=YLGMN
      IF (X.GT.XLGMN) ALOGX=DLOG(X)
      F=A22*ALOGX+A21*X-Y
      if(f.gt.0.D0)then
        xmin=x
        goto 300
      elseif(f.lt.0.D0)then
        xmax=x
        goto 300
      elseif(f.eq.0.D0)then
       return
      endif
      endif
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_EQTNC2(F,FP1,FP2,B2,A21,A22,C1,C2,X,Y,NSOL,
     1 					ALFA)
      implicit double precision (a-h, o-z)
      dimension X(4),Y(0:4)

      XL=X(1)
      XU=X(2)
      F=-B2
      FP1=0.D0
      FP2=0.D0
      IF (NSOL.GE.2) THEN
       CALL S_INTGAM(1,0.D0,XL,ALFA,SUM1)
       CALL S_INTGAM(4,XL,XU,ALFA,SUM2)
       CALL S_INTGAM(2,XL,XU,ALFA,SUM3)
       CALL S_INTGAM(1,0.D0,XU,ALFA,SUM4)
       F=Y(0)*SUM1+(A22*SUM2+A21*SUM3-(A22*C2+A21*C1)*(SUM4-SUM1))
     *   +Y(2)*(1.D0-SUM4)
       FP1=-A21*(SUM4-SUM1)
       FP2=-A22*(SUM4-SUM1)
      ENDIF
      IF (NSOL.EQ.4) THEN
       XL=X(3)
       XU=X(4)
       F=F-Y(2)*(1.D0-SUM4)
       CALL S_INTGAM(1,0.D0,XL,ALFA,SUM5)
       CALL S_INTGAM(4,XL,XU,ALFA,SUM6)
       CALL S_INTGAM(2,XL,XU,ALFA,SUM7)
       CALL S_INTGAM(1,0.D0,XU,ALFA,SUM8)
       F=F+Y(2)*(SUM5-SUM4)+Y(4)*(1.D0-SUM8)+
     *    (A22*SUM6+A21*SUM7-(A22*C2+A21*C1)*(SUM8-SUM5))
       FP1=FP1-A21*(SUM8-SUM5)
       FP2=FP2-A22*(SUM8-SUM5)
      ENDIF
      RETURN
      END
C
C----------------------------------------------------------------------
C
      SUBROUTINE S_EQTNC1(F,FP1,FP2,B1,A11,C1,ALFA)
      implicit double precision (a-h, o-z)
C
      B=B1
      XL=-B/A11+C1
      XU=B/A11+C1
      SB=B
      IF (XL.GT.XU) THEN
        TMP=XL
        XL=XU
        XU=TMP
        SB=-B
      ENDIF
      IF (XL.LT.0.D0) XL=0.D0
      CALL S_INTGAM(1,0.D0,XL,ALFA,SUM1)
      CALL S_INTGAM(2,XL,XU,ALFA,SUM2)
      CALL S_INTGAM(1,0.D0,XU,ALFA,SUM3)
      F=-SB*SUM1+A11*SUM2-A11*C1*(SUM3-SUM1)+SB*(1.D0-SUM3)
      FP1=-A11*(SUM3-SUM1)
      FP2=0.D0
      RETURN
      END
C
C----------------------------------------------------------------------
C
      SUBROUTINE S_SOLC12(MAXIT,TOL,ALPHA,CALF,ZERO,NIT,X,Y,NSOL,
     1 A11,A21,A22,C1,C2,B1,B2)
      implicit double precision (a-h, o-z)
      double precision lamda
      dimension CALF(2),ZERO(2)
      DATA TIL/1.D-6/
C
C  STEP 0.   INITIALIZATIONS
C  ------
C
      NIT=1
      TOL2=TOL*TOL
      C1=CALF(1)
      C2=CALF(2)
      ALFA=ALPHA
      SIGM=1.D0
        CALL S_EQTNC1(F10,F1A,F1B,B1,A11,C1,ALFA)
        CALL S_EQTNC2(F20,F2A,F2B,B2,A21,A22,C1,C2,X,Y,NSOL,ALFA)
        MADE=1
      S=F10**2+F20**2
      IF (S.LT.TOL2) GOTO 200
C
C  STEP 1.   COMPUTE NEW VALUE of (C1,C2) AND CHECK CONVERGENCE
C  ------
C
  100 C01=C1
      C02=C2
      LAMDA=0.D0
      S0=S
  110 F1A=F1A+LAMDA
      F2B=F2B+LAMDA
      D=F1A*F2B-F1B*F2A
      IF (ABS(D).LT.TIL) THEN
        LAMDA=LAMDA+DSQRT(TIL)
        GOTO 110
      ENDIF
      DLT1=( F2B*F10-F1B*F20)/D
      DLT2=(-F2A*F10+F1A*F20)/D
      GAM1=1.D0
      GAM2=1.D0
      NSTP=0
  150 C1=C01-GAM1*DLT1
      C2=C02-GAM2*DLT2
      CALL S_SOLVX(B2,TOL,NSOL,X,Y,A21,A22,C1,C2)
      CALL S_EQTNC1(F10,F1A,F1B,B1,A11,C1,ALFA)
      CALL S_EQTNC2(F20,F2A,F2B,B2,A21,A22,C1,C2,X,Y,NSOL,ALFA)
C
C the above call to s_eqtnc2 produces log(-0.42..)
C because s_solvx produces negative X's ... 
C because sign(a21) = sign(a22)
C which should not happen... 
C	  return
C
C
      S=F10**2+F20**2
      IF (S.LT.TOL2) GOTO 200
      IF (S.GT.S0.AND.NSTP.LT.10) THEN
        NSTP=NSTP+1
        GAM1=GAM1/2.D0
        GAM2=GAM2/2.D0
        GOTO 150
      ENDIF
      IF (NIT.EQ.MAXIT) GOTO 200
      NIT=NIT+1
      GOTO 100
C
C  STEP 2.   EXIT
C  ------
  200 CALF(1)=C1
      CALF(2)=C2
      ZERO(1)=F10
      ZERO(2)=F20
      RETURN
      END

      SUBROUTINE S_LNTRP0(MDT,TAB,ALPHA,C1,C2,A11,A21,A22,
     1 				ALPHA1,ALPHA2,DELTA,K)
      implicit double precision (a-h, o-z)
      dimension TAB(MDT,5),VAL(5)

      IF (ALPHA.LE.ALPHA1) THEN
        C1=TAB(1,1)
        C2=TAB(1,2)
        A11=TAB(1,3)
        A21=TAB(1,4)
        A22=TAB(1,5)
      ELSEIF (ALPHA.GE.ALPHA2) THEN
        C1=TAB(K,1)
        C2=TAB(K,2)
        A11=TAB(K,3)
        A21=TAB(K,4)
        A22=TAB(K,5)
      ELSE 
        KL=INT((ALPHA-ALPHA1)/DELTA)+1
        KU=KL+1
        DO 100 IOPT=1,5
         VAL(IOPT)=TAB(KL,IOPT)
     1   +(TAB(KU,IOPT)-TAB(KL,IOPT))
     2   *(ALPHA-DBLE(KL-1)*DELTA-ALPHA1)/DELTA
  100   CONTINUE
        C1=VAL(1)
        C2=VAL(2)
        A11=VAL(3)
        A21=VAL(4)
        A22=VAL(5)
      ENDIF
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      DOUBLE PRECISION FUNCTION S_SEQTN9(SIGMA,Y,NOBS,PARAM)
      implicit double precision (a-h, o-z)
      DIMENSION Y(NOBS), PARAM(5)
      EXTERNAL S_PSI2
      DATA NCALL,XLGMN,YLGMN/0,0.D0,0.D0/
	  A21 = PARAM(1)
	  A22 = PARAM(2)
	  C1  = PARAM(3)
	  C2  = PARAM(4)
	  B2  = PARAM(5)
      IF (NCALL.EQ.0) THEN
        NCALL=1
        CALL S_MACHD(4,XLGMN)
        CALL S_MACHD(5,YLGMN)
      ENDIF
      SUM=0.D0
      EN=DBLE(NOBS)
      DO 120 I=1,NOBS
        S=Y(I)/SIGMA
        ALOGS=YLGMN
        IF (S.GT.XLGMN) ALOGS=DLOG(S)
        S=A22*(ALOGS-C2)+A21*(S-C1)
        SUM=SUM+S_PSI2(S,B2)
  120 CONTINUE
      S_SEQTN9=SUM/EN
      RETURN
      END
C
C------------------------------------------------------------------------
C
      DOUBLE PRECISION FUNCTION S_SEQTN10(SIGMA,Y,NOBS,PARAM)
      implicit double precision (a-h, o-z)
      DIMENSION Y(NOBS),PARAM(3)
      EXTERNAL S_PSI1

	  A11 = PARAM(1)
	  C1  = PARAM(2)
	  B1  = PARAM(3)

      SUM=0.D0
      EN=DBLE(NOBS)
      DO 120 I=1,NOBS
        S=A11*(Y(I)/SIGMA-C1)
        SUM=SUM+S_PSI1(S,B1)
  120 CONTINUE
      S_SEQTN10=SUM/EN
      RETURN
      END
C
C------------------------------------------------------------------------
C
      DOUBLE PRECISION FUNCTION S_PSI1(S,B1)
      implicit double precision (a-h, o-z)

      ABST=DABS(S)
      TMP=DMIN1(B1,ABST)
      IF (S.LT.0.D0) TMP=-TMP
      S_PSI1=TMP
      RETURN
      END
C
C------------------------------------------------------------------------
C
      DOUBLE PRECISION FUNCTION S_PSI2(S,B2)
      implicit double precision (a-h, o-z)

      ABST=DABS(S)
      TMP=DMIN1(B2,ABST)
      IF (S.LT.0.D0) TMP=-TMP
      S_PSI2=TMP
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_RGFLD(F,V,Y,A,B,TOL,MAXIT,X,ITERM,NOBS,PARAM)
C
C PARAM is a vector of parameters for F
C
      implicit double precision (a-h, o-z)
      DIMENSION V(NOBS)
      EXTERNAL F
      DATA TL/1.D-10/
C
C  INITIALIZE
C
      ITR=1
      FA=F(A,V,NOBS,PARAM)-Y
      FB=F(B,V,NOBS,PARAM)-Y
C
C  REGULA FALSI ITERATION
C
   20 IF (DABS(FA-FB).GT.TL) GOTO 30
      RETURN
   30 XN=(A*FB-B*FA)/(FB-FA)
      FN=F(XN,V,NOBS,PARAM)-Y
C
C  TEST TO SEE IF MAXIMUM NUMBER OF ITERATIONS HAS BEEN EXECUTED
C
      IF (ITR.GE.MAXIT) GOTO 60
C
C  TEST TO SEE IF ROOT HAS BEEN FOUND
C
      IF (DABS(FN).LT.TOL) GOTO 70
      IF (FA*FN.LE.0.D0) GOTO 40
      A=XN
      FA=FN
      GOTO 50
   40 B=XN
      FB=FN
C
C  INCREMENT ITERATION COUNTER
C
   50 ITR=ITR+1
      GOTO 20

   60 ITERM=2
      X=XN
      RETURN
   70 ITERM=1
      X=XN
      RETURN
      END


      SUBROUTINE S_ESTIMP(Y,NOBS,TAB,MDT,LA,MAXIT,TPAR,TOL,ALFA1,ALFA2,
     +           ALPHA,SIGMA,NIT,c1c2,a123)
C
C   INPUT: Y(NOBS)    Observations
C          TAB(MDT,5) Table of A, c1 and c2 for given b1,b2.
C          LA =       1 if A==(1, 0, 1), 2 otherwise.
C          TPAR       Param. used for TAB (b1,b2,ALPHA1,ALPHA2, DELTA)
C          ALFA1      Search starts at ALFA1 if ALFA1!=0 otherwise ALPHA1
C          ALFA2      Search ends   at ALFA2 if ALFA2!=0 otherwise ALPHA2
C          TOL        Tolerance
C
C   OUTPUT: NIT = 0   No solution found for ALPHA in [ALFA1,ALFA2]
C           NIT = 1   Solution = (ALPHA, SIGMA=MU, C1C2, A123)
C
      implicit double precision (a-h, o-z)
      DIMENSION Y(NOBS),TAB(MDT,5),TPAR(6),c1c2(2),a123(3),A(3)
	  DIMENSION SIGN9(2), PARAM(5)
      EXTERNAL S_SEQTN9,S_SEQTN10  
C
C  Read data and table info
C

      b1=tpar(1)
      b2=tpar(2)
      alpha1=tpar(3)
      alpha2=tpar(4)
      k=int(tpar(5))
      DELTA=tpar(6)
      N=NOBS

      SIG0=DBLE(SIGMA)
      SIGM10=SIG0
      ITERMY=1
      TIL=TOL
      TOLD=DBLE(TOL)
      IF (DELTA.GE.2.D0) THEN
        DLTA=0.2D0
      ELSEIF (DELTA.LE.0.2D0) THEN
        DLTA=DELTA
      ELSEIF (DELTA.LE.0.4D0) THEN
        DLTA=DELTA/2.D0
      ELSEIF (DELTA.LE.0.8D0) THEN
        DLTA=DELTA/4.D0
      ELSE
        DLTA=DELTA/8.D0
      ENDIF
      ALF1=ALFA1
      IF (ALF1.EQ.0.D0) ALF1=ALPHA1
      ALF2=ALFA2
      IF (ALF2.EQ.0.D0) ALF2=ALPHA2
      NIT=0
      NRFN=0
      SIGN9(1)=-9.D0
      SIGN9(2)=-9.D0
      I9=2
      ALF9=0.D0
      SIG9=0.D0
      NK=-1
  100 NK=NK+1
      ALFA=ALF1+DBLE(NK)*DLTA
      IF (ALFA.GT.ALF2) GOTO 500        
      IF (MDT.LE.2) THEN
        MAXTA=1
        MAXTC=1
        IF (SIG0.NE.0.D0) MAXTC=20
        CALL S_CRETABI(B1,B2,1,LA,A,MAXTA,MAXTC,MAXIT,TIL,TOL,
     +  			ALFA,ALFA,0,TAB,TPAR)
      ELSE
        CALL S_LNTRP0(MDT,TAB,ALFA,C1,C2,A11,A21,A22,
     1 			ALPHA1, ALPHA2, DELTA, K)
      ENDIF
C
C  Special case: Solve only the 2nd equation for alpha
C

	  PARAM(1) = A21
	  PARAM(2) = A22
	  PARAM(3) = C1
	  PARAM(4) = C2
	  PARAM(5) = B2

      IF (SIG0.NE.0.D0) THEN
        IF (NIT.EQ.1) THEN
          ALF9=ALFA
          NRFN=NRFN+1
          SIGN9(I9)=S_SEQTN9(SIG0,Y,NOBS,PARAM)
          GOTO 300
        ENDIF
        I9=3-I9
        SIGN9(I9)=S_SEQTN9(SIG0,Y,NOBS,PARAM)
        GOTO 120
      ENDIF
C
C  Solve equation 10 for sigma
C
      SMIN=DBLE(Y(1)/C1)  
      SMAX=DBLE(Y(NOBS)/C1)
	  PARAM(1) = A11
	  PARAM(2) = C1
	  PARAM(3) = B1
      FMAX=S_SEQTN10(SMIN,Y,NOBS,PARAM)
      FMIN=S_SEQTN10(SMAX,Y,NOBS,PARAM)
      IF     (FMAX.LT.0.D0) THEN
             ITERMy=4
             SIGM10=SMIN
      ELSEIF (FMIN.GT.0.D0) THEN
             ITERMy=3
             SIGM10=SMAX
      ELSE
	   PARAM(1) = A11
	   PARAM(2) = C1
	   PARAM(3) = B1
       CALL S_RGFLD(S_SEQTN10,Y,0.D0,SMIN,SMAX,TOLD,MAXIT,SIGM10,
     1				ITERMY,NOBS,PARAM)
      ENDIF
      IF (NIT.EQ.1) GOTO 200
      IF (ITERMY.NE.1) GOTO 100
      I9=3-I9

	  PARAM(1) = A21
	  PARAM(2) = A22
	  PARAM(3) = C1
	  PARAM(4) = C2
	  PARAM(5) = B2

      SIGN9(I9)=S_SEQTN9(SIGM10,Y,NOBS,PARAM)
  120 TMP=DABS(SIGN9(I9))
      IF (SIGN9(2).EQ.-9.D0) THEN
        FMIN9=DABS(SIGN9(1))
        SIGN9(2)=SIGN9(1)
        ALF9=ALFA
        SIG9=DBLE(SIGM10)
        GOTO 100
      ENDIF
      IF (TMP.LE.FMIN9) THEN
        ALF9=ALFA
        SIG9=DBLE(SIGM10)
        FMIN9=TMP
      ENDIF
      IF (SIGN9(1)*SIGN9(2).GT.0.D0) GOTO 100
      NIT=1
C
C The solution is between ALFA-DLTA and ALFA. Refinement step
C
  150 NK=2*NK-2
      DLTA=DLTA/2.D0
      GOTO 100
  200 NRFN=NRFN+1
      ALF9=ALFA
      SIG9=DBLE(SIGM10)
      IF (SIG0.EQ.0.D0) THEN
	  PARAM(1) = A21
	  PARAM(2) = A22
	  PARAM(3) = C1
	  PARAM(4) = C2
	  PARAM(5) = B2
	  SIGN9(I9) = S_SEQTN9(SIGM10,Y,NOBS,PARAM)
	  ENDIF
  300 IF (SIGN9(1)*SIGN9(2).GT.0.D0) THEN
        NK=2*NK
        DLTA=DLTA/2.D0
        I9=3-I9
        IF (NRFN.LE.10) GOTO 100
      ELSE
        IF (NRFN.LE.10) GOTO 150       
      ENDIF  
  500 ALPHA=ALF9
      SIGMA=SIG9
      ALFA=ALPHA
      SIGM=SIGMA 
      c1c2(1)=c1
      c1c2(2)=c2
      a123(1)=a11
      a123(2)=a21
      a123(3)=a22
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_GAMLIK(Y,N,MAXIT,TOL,ALPHA,SIGMA,YBAR,VAR,ZERO,NIT)
C
C Solution of (1/n)*Sum(alog(y/ybar)) + alog(alpha) - digama(alpha)=0
C and         alpha*sigma=ybar for (alpha,sigma)
C
      implicit double precision (a-h, o-z)
      DIMENSION Y(N)
      EXTERNAL S_GAMDIGAMA,S_GAMTRIGAM
      DATA NCALL,XLGMN,YLGMN,TIL/0,0.D0,0.D0,1.D-6/
C
C Compute sample mean and variance; set initial values
C
      NIT=1
      IF (NCALL.EQ.0) THEN
        NCALL=1
        CALL S_MACHD(4,XLGMN)
        CALL S_MACHD(5,YLGMN)
      ENDIF

      SUMLN=0.D0
      SUM=0.D0
      EN=dble(N)

      DO 10 I=1,N
      XI=Y(I)
      SUM=SUM+XI
      ALOGX=YLGMN
      IF (XI.GT.XLGMN) ALOGX=DLOG(XI)
      SUMLN=SUMLN+ALOGX
   10 CONTINUE
      YBAR=SUM/EN

      SUM=0.D0
      DO 15 I=1,N
   15 SUM=SUM+(Y(I)-YBAR)**2
      VAR=SUM/EN
      SIGM0=VAR/YBAR
      ALF0=YBAR/SIGM0
      ALOGX=YLGMN
      IF (YBAR.GT.XLGMN) ALOGX=DLOG(YBAR)
      G=SUMLN/EN-ALOGX
C
C Compute the objective function and its derivative
C
  100 ALFA=ALF0
      ALOGX=YLGMN
      IF (ALFA.GT.XLGMN) ALOGX=DLOG(ALFA)
      DEN=ALFA
      IF (ALFA.LT.TIL) DEN=TIL
      F=ALOGX-S_GAMDIGAMA(DEN)+G
      FP=1.D0/DEN - S_GAMTRIGAM(DEN)
C
C Compute new values
C
      NSTP=1
      IF (ABS(FP).LT.TIL) FP=SIGN(TIL,FP)
      ALF0=ALFA-F/FP
  200 IF (ALF0.LE.0.) THEN
        NSTP=NSTP+1
        FP=2.*FP
        ALF0=ALFA-F/FP
        GOTO 200
      ENDIF
      ALOGX=YLGMN
      IF (ALF0.GT.XLGMN) ALOGX=DLOG(ALF0)
      ZERO=ALOGX-S_GAMDIGAMA(ALF0)+G
      IF (ABS(ZERO).LT.TOL) GOTO 320
      IF (ABS(ALFA-ALF0).LT.DMIN1(1.D0,DABS(ALF0))*TOL.AND.NSTP.LE.2)
     1    GOTO 300
      IF (NIT.EQ.MAXIT) GOTO 300
      NIT=NIT+1
      GOTO 100
C
C Exit
C
  300 ALOGX=YLGMN
      IF (ALF0.GT.XLGMN) ALOGX=DLOG(ALF0)
      ZERO=ALOGX-S_GAMDIGAMA(ALF0)+G
  320 ALPHA=ALF0
      SIGMA=YBAR/ALPHA
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      double precision FUNCTION S_GAMMA(SIGMA,ALFA,X)
      implicit double precision (a-h, o-z)
      DATA NCALL,XLGMN,YLGMN,GALIM/0,0.D0,0.D0,0.D0/
      IF (NCALL.EQ.0) THEN
        NCALL=1
        CALL S_MACHD(4,XLGMN)
        CALL S_MACHD(5,YLGMN)
        GALIM=DLOG(1.D-10)
      ENDIF
      S_GAMMA=0.D0
      IF (X.EQ.0.D0) RETURN
      S=X/SIGMA
      ALOGS=YLGMN
      IF (S.GT.XLGMN) ALOGS=DLOG(S)
      ALF=DBLE(ALFA)
      V=ALF
      F=0.D0
      IF (ALF.GE.7.D0) GOTO 300
      F=1.D0
      Z=ALF-1.D0
  100 Z=Z+1.D0
      IF (Z.GE.7.D0) GOTO 200
      V=Z
      F=F*Z
      GOTO 100
  200 V=V+1.D0
      F=-DLOG(F)
  300 Z=1.D0/(V*V)
      GL=F+(V-0.5D0)*DLOG(V)-V+.9189385332D0+(((-.000595238D0*Z+
     +   .0007936507D0)*Z - .0027777778D0)*Z+.0833333333D0)/V
      ALOGAM=(ALF-1.D0)*ALOGS-S-DLOG(SIGMA)-GL
      IF (ALOGAM.LT.GALIM) RETURN
      S=DEXP(ALOGAM)
      S_GAMMA=S    
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      double precision FUNCTION S_GAMDIGAMA(X)
      implicit double precision (a-h, o-z)
      T=0.D0
      Z=DBLE(X)
      IF (X.LT.5.D0) THEN
        N=5-INT(X+1.D-10)
        DO 100 K=1,N
          T=T+1.D0/Z
          Z=Z+1.D0
  100   CONTINUE
      ENDIF
      Z2=1.D0/(Z*Z)
      S=DLOG(Z) - 1.D0/(2.D0*Z) + Z2*(- 1.D0/12.D0 + Z2*(1.D0/120.D0 +
     + Z2*(-1.D0/252.D0 + Z2*(1.D0/240.D0 + Z2*(- 1.D0/132.D0 + Z2*(
     + 691.D0/(12.D0*2730.D0) - Z2/12.D0)))))) - T
      S_GAMDIGAMA=S
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      double precision FUNCTION S_GAMTRIGAM(X)
      implicit double precision (a-h, o-z)
      T=0.D0
      Z=DBLE(X)
      IF (X.LT.5.D0) THEN
        N=5-INT(X+1.D-10)
        DO 100 K=1,N
          T=T-1.D0/(Z*Z)
          Z=Z+1.D0
  100   CONTINUE
      ENDIF
      Z2=1.D0/(Z*Z)
      Z3=1.D0/(Z*Z*Z)
      S=1.D0/Z + Z2/2.D0 + Z3*(1.D0/6.D0 + Z2*(- 1.D0/30.D0 + Z2*(
     + 1.D0/42.D0 + Z2*(- 1.D0/30.D0 + Z2*(5.D0/66.D0 + Z2*(-691.D0/
     + 2730.D0 + Z2*(7.D0/6.D0))))))) - T
      S_GAMTRIGAM=S
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_LIMGAM(SIGMA,ALFA,LOWER,UPPER)
      implicit double precision (a-h, o-z)
      double precision LOWER
      DATA NCALL,XLGMN,YLGMN,GALIM/0,0.D0,0.D0,0.D0/
      IF (NCALL.EQ.0) THEN
        NCALL=1
        CALL S_MACHD(4,XLGMN)
        CALL S_MACHD(5,YLGMN)
        GALIM=DLOG(1.D-9)
      ENDIF
      LOWER=0.D0
      CALL S_LGAMAD(ALFA,GL)
      IF (ALFA.LE.5.D0) GOTO 250
      X=ALFA
  100 X=X-0.1D0
      IF (X.LE.0.D0) GOTO 250
      S=X/SIGMA
      ALOGS=YLGMN
      IF (S.GT.XLGMN) ALOGS=DLOG(S)
      ALOGAM=(ALFA-1.D0)*ALOGS-S-DLOG(SIGMA)-GL
      IF (ALOGAM.GT.GALIM) GOTO 100
  200 LOWER=X
  250 X=ALFA
  300 X=X+0.1D0
      S=X/SIGMA
      ALOGS=YLGMN
      IF (S.GT.XLGMN) ALOGS=DLOG(S)
      ALOGAM=(ALFA-1.D0)*ALOGS-S-DLOG(SIGMA)-GL
      IF (ALOGAM.GT.GALIM) GOTO 300
  400 UPPER=X
      RETURN
      END
c
c***********************************************************************
c
      SUBROUTINE S_SUMLGM(HI,ALPHA,GL)
C
C  INT  Log(x)*gamma(x,alpha) dx for x=0 to HI
C
      implicit double precision (a-h, o-z)
      DOUBLE PRECISION ALF,ALPHA,HI,LOGHI,SUM,GA1,GG,GL,GX,
     1       PREC,SS,TERM
      DATA NCALL,PREC/0,0.D0/
      IF (NCALL.EQ.0) THEN
        NCALL=1
        CALL S_MACHD(2,PREC)
      ENDIF
      GL=0.D0
      IF (HI.LE.0.D0) RETURN
      ALF=ALPHA
      LOGHI=DLOG(HI)
      CALL S_LGAMAD(ALF+1.D0,GA1)
      GG=ALF*LOGHI-HI-GA1
      SS=1.D0/ALF
      SUM=DEXP(GG+DLOG(SS))
  100 ALF=ALF+1.D0
      GG=GG+LOGHI-DLOG(ALF)
      SS=SS+1.D0/ALF
      TERM=DEXP(GG+DLOG(SS))
      SUM=SUM+TERM
      IF (TERM.GT.PREC) GOTO 100
      CALL S_INGAMD(HI,ALPHA,GX)
      GL=LOGHI*GX-SUM
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_SUMLG2(HI,ALPHA,GL)
C
C  INT  [LOG(x)]^2*Gamma(x,ALPHA) dx for x=0 to HI
C
      implicit double precision (a-h, o-z)
      DOUBLE PRECISION ALF,ALFA,ALPHA,GA1,GG,GL,GX,HI,LOGHI,PREC,
     1       SUM,SSUM,SS,TERM,TRM
      DATA NCALL,PREC/0,0.D0/
      IF (NCALL.EQ.0) THEN
        NCALL=1
        CALL S_MACHD(2,PREC)
      ENDIF
      GL=0.D0
      IF (HI.LE.0.) RETURN
      LOGHI=DLOG(HI)
      ALFA=ALPHA-1.D0
      SSUM=0.D0
  100 ALFA=ALFA+1.D0
      ALF=ALFA
      CALL S_LGAMAD(ALF+1.D0,GA1)
      GG=ALF*LOGHI-HI-GA1
      SS=1.D0/ALF
      SUM=DEXP(GG+DLOG(SS))
  200 ALF=ALF+1.D0
      GG=GG+LOGHI-DLOG(ALF)
      SS=SS+1.D0/ALF
      TERM=DEXP(GG+DLOG(SS))
      SUM=SUM+TERM
      IF (TERM.GT.PREC) GOTO 200
      CALL S_INGAMD(HI,ALFA,GX)
      SUM=LOGHI*GX-SUM
      TRM=SUM/ALFA
      SSUM=SSUM+TRM
      IF (DABS(TRM).GT.1.D-8) GOTO 100
      CALL S_INGAMD(HI,ALPHA,GX)
      GL=LOGHI*LOGHI*GX-2.D0*SSUM
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_INTGAM(IOPT,XL,XU,ALFA,SUM)
      implicit double precision (a-h, o-z)
      DOUBLE PRECISION LO,HI,ALF,X1,X2,VAL1,VAL2
      LO=DBLE(XL)
      HI=DBLE(XU)
      ALF=DBLE(ALFA)
      SIGM=1.
      CALL S_LIMGAM(SIGM,ALFA,XLOW,XUP)
      X1=LO
      X2=HI
      IF (X1.GT.DBLE(XUP)) X1=DBLE(XUP)
      IF (X2.GT.DBLE(XUP)) X2=DBLE(XUP)
      VAL1=0.D0
      GOTO (10,20,30,40,50,60) IOPT
   10 IF (X1.NE.0.D0) CALL S_INGAMD(X1,ALF,VAL1)
      CALL S_INGAMD(X2,ALF,VAL2)
      SUM=(VAL2-VAL1)
      RETURN
   20 IF (X1.NE.0.D0) CALL S_INGAMD(X1,ALF+1.D0,VAL1)
      CALL S_INGAMD(X2,ALF+1.D0,VAL2)
      SUM=(ALF*(VAL2-VAL1))
      RETURN
   30 IF (X1.NE.0.D0) CALL S_INGAMD(X1,ALF+2.D0,VAL1)
      CALL S_INGAMD(X2,ALF+2.D0,VAL2)
      SUM=(ALF*(ALF+1.D0)*(VAL2-VAL1))
      RETURN
   40 IF (X1.NE.0.D0) CALL S_SUMLGM(X1,ALF,VAL1)
      CALL S_SUMLGM(X2,ALF,VAL2)
      SUM=(VAL2-VAL1)
      RETURN
   50 IF (X1.NE.0.D0) CALL S_SUMLGM(X1,ALF+1.D0,VAL1)
      CALL S_SUMLGM(X2,ALF+1.D0,VAL2)
      SUM=(ALF*(VAL2-VAL1))
      RETURN
   60 IF (X1.NE.0.) CALL S_SUMLG2(X1,ALF,VAL1)
      CALL S_SUMLG2(X2,ALF,VAL2)
      SUM=(VAL2-VAL1)
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_INGAMD(X,P,G)

      implicit double precision (a-h, o-z)
      DOUBLE PRECISION X,PN(6),P,G,GP,GIN,OFLO,FACTOR,RN,TERM,TOL,
     1                 A,B,AN,DIF,S_XEXPD
      EXTERNAL S_XEXPD
      DATA TOL/1.0D-8/
      G=0.D0
      IF (X.EQ.0.D0) RETURN
      CALL S_MACHD(6,OFLO)
      OFLO=OFLO*1.D-15
      CALL S_LGAMAD(P,GP)
      GIN=0.D0
      FACTOR=S_XEXPD(P*DLOG(X)-X-GP)
      IF (X.GT.1.D0.AND.X.GE.P) GOTO 30
C
C  CALCULATION BY SERIES EXPANSION
C
      GIN=1.D0
      TERM=1.D0
      RN=P
   20 RN=RN+1.D0
      TERM=TERM*X/RN
      GIN=GIN+TERM
      IF (TERM.GT.TOL) GOTO 20
      GIN=GIN*FACTOR/P
      GOTO 50
C
C  CALCULATION BY CONTINUED FRACTION
C
   30 A=1.D0-P
      B=A+X+1.D0
      TERM=0.D0
      PN(1)=1.D0
      PN(2)=X
      PN(3)=X+1.D0
      PN(4)=X*B
      GIN=PN(3)/PN(4)
   32 A=A+1.D0
      B=B+2.D0
      TERM=TERM+1.D0
      AN=A*TERM
      DO 33 I=1,2
   33 PN(I+4)=B*PN(I+2)-AN*PN(I)
      IF (PN(6).EQ.0.D0) GOTO 35
      RN=PN(5)/PN(6)
      DIF=DABS(GIN-RN)
      IF (DIF.GT.TOL) GOTO 34
      IF (DIF.LE.TOL*RN) GOTO 42
   34 GIN=RN
   35 DO 36 I=1,4
   36 PN(I)=PN(I+2)
      IF (DABS(PN(5)).LT.OFLO) GOTO 32
      DO 41 I=1,4
   41 PN(I)=PN(I)/OFLO
      GOTO 32
   42 GIN=1.D0-FACTOR*GIN
   50 G=GIN
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_LGAMAD(X,GL)

      implicit double precision (a-h, o-z)
      DOUBLE PRECISION X,GL,V,F,Z
      V=X
      F=0.D0
      IF (X.GE.7.D0) GOTO 300
      F=1.D0
      Z=X-1.D0
  100 Z=Z+1.D0
      IF (Z.GE.7.D0) GOTO 200
      V=Z
      F=F*Z
      GOTO 100
  200 V=V+1.D0
      F=-DLOG(F)
  300 Z=1.D0/V**2
      GL=F+(V-0.5D0)*DLOG(V)-V+.9189385332D0+(((-.000595238D0*Z+
     +   .0007936507D0)*Z - .0027777778D0)*Z+.0833333333D0)/V
      RETURN
      END

      subroutine s_sdigama(s,result)
      implicit double precision (a-h, o-z)
       double precision s,result,s_gamdigama
       external s_gamdigama
       result=s_gamdigama(s)
      end
c
c***********************************************************************
c
      subroutine s_strigamma(s,result)
      implicit double precision (a-h, o-z)
       external s_gamtrigam
       result=s_gamtrigam(s)
      end
C
C======================================================================
C
      DOUBLE PRECISION FUNCTION S_EXU(Z,
     * JPSI,JPS0,SIGM,
     1 A11,A21,A22,C1,C2,B1,B2)
      implicit double precision (a-h, o-z)
      dummy = jpsi+jps0+sigm+a11+a21+a22+c1+c2+b1+b2
      S_EXU=DBLE(Z)
      RETURN 
      END


      SUBROUTINE S_AUXVAS(til,m,q,alfa,sigm,a11,
     1 a21,a22,b1,b2,c1,c2,xb,yb,ns,digam,beta)
	  implicit double precision (a-h, o-z)
	  double precision M(4)
      dimension Q(4),wgt(2),xb(8),yb(8,2)
	  dimension work(320), iwork(80)
      external s_psipsi,s_gamma,s_dpsi,s_psis
      tild=dble(til)
      key=1
      limit=80
C
C  COMPUTE M
C
      DO 100 iopt=1,4
      wgt(1)=dble(iopt)
      ts=0.d0
      do 10 i=1,ns-1
      wgt(2)=dble(i)
      call s_intgrd(s_psis,wgt,2,s_dpsi,s_gamma,xb(i),xb(i+1),
     1		tild,0.d0,key,limit,t,errst,neval,ier,work,iwork,
     2		alfa,sigm,
     3		a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
      ts=t+ts
  10  continue
      M(iopt)=ts
  100 CONTINUE
C
C   COMPUTE Q
C
      DO 200 iopt=1,4
        wgt(1)=dble(iopt)
      ts=0.d0
      do 20 i=1,ns-1
      wgt(2)=i
      call s_intgrd(s_psipsi,wgt,2,s_dpsi,s_gamma,xb(i),xb(i+1),
     1		tild,0.d0,key,limit,t,errst,neval,ier,work,iwork,
     2		alfa,sigm,
     3		a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)

      ts=ts+t
   20 continue
      Q(iopt)=ts
  200 continue
      RETURN
      END

c================================================================

      double precision FUNCTION S_SCORC(X,IS,SIGM,C1,C2)
c
c       SCORES CORRIGES
c       IS=1   df/dtau=SC1=S-C1
c       IS=2   df/da  =SC2=LOG(S)-C2
c
      implicit double precision (a-h, o-z)
      DATA NCALL,XLGMN,YLGMN/0,0.D0,0.D0/
      IF(NCALL.EQ.0)THEN
         NCALL=1
         CALL s_MACHd(4,XLGMN)
         CALL s_machd(5,YLGMN)
      ENDIF
      S=X/SIGM
      GOTO (10,20) IS
   20 ALOGS=YLGMN
      IF (S.GT.XLGMN) ALOGS=DLOG(S)
      S_SCORC=ALOGS-C2
      RETURN
   10 S_SCORC=S-C1
      RETURN
      END
C
C------------------------------------------------------------
C
      double precision FUNCTION S_SCOR(X,alfa,sigm,is,digam)
c
c       is=1   S1=s-alf
c       is=2   S2=log(x)-digama(alfa)
c
      implicit double precision (a-h, o-z)
      DATA NCALL,XLGMN,YLGMN/0,0.D0,0.D0/
      IF(NCALL.EQ.0)THEN
         NCALL=1
         CALL S_MACHd(4,XLGMN)
         CALL S_machd(5,YLGMN)
      ENDIF
      S=X/SIGM
      GOTO (10,20) IS
   20 ALOGS=YLGMN
      IF(S.GT.XLGMN) ALOGS=DLOG(S)
      S_SCOR=ALOGS-digam
      RETURN
   10 S_SCOR=(S-alfa)
      RETURN
      END
CC
CC=============================================================
C
      double precision FUNCTION S_ZSCOR(X,IZ,SIGM,A11,
     1				A21,A22,C1,C2)
C
C       scores combines
C       iz=1  z1=a11*sc1
C       iz=2  z2=a21*sc1+a22*sc2
C
      implicit double precision (a-h, o-z)
      EXTERNAL S_SCORC
       sc1=s_scorc(x,1,SIGM,C1,C2)
       sc2=s_scorc(x,2,SIGM,C1,C2)
       GOTO (10,20) IZ
   10   S_ZSCOR=a11*sc1
        RETURN
   20   S_ZSCOR=a21*sc1+a22*sc2
        RETURN
        END
C=============================================================
C   fonctions psi et psip - partitionned parameter
C   routines auxvas-auxvasp
c==============================================================
c

      DOUBLE PRECISION FUNCTION S_DPSI(X,JPSI,JPS0,SIGM,
     1			A11,A21,A22,C1,C2,B1,B2)
C
C    jpsi=1  psi=psi1(z1)
c    jpsi=2  psi=psi2(z2)
c    jps0=-1 psi=-b   jps0=0 psi=z  jps0=1 psi=b
C
      implicit double precision (a-h, o-z)
      EXTERNAL S_ZSCOR
        IZ=JPSI
        ZS=S_ZSCOR(X,IZ,SIGM,A11,A21,A22,C1,C2)
        BS=B2
        IF (JPSI.EQ.1) BS=B1
        IF (JPS0.EQ.0) THEN
          S_DPSI=DBLE(ZS)
        ELSEIF (JPS0.EQ.-1) THEN
          S_DPSI=-DBLE(BS)
        ELSEIF (JPS0.EQ.1) THEN
          S_DPSI=DBLE(BS)
        ENDIF
      RETURN
      END
C
C--------------------------------------------------------------
C
      DOUBLE PRECISION FUNCTION S_PSIS(Dx,WGT,N,EXPSI,EXGAM,
     1			alfa, sigm, a11, a21, a22,
     2			b1, b2, c1, c2, yb, digam, beta)
C
C      psi *score
c     IOPT=1  psis=psi1*s1  IOPT=3 psis=psi1*s2
c     IOPT=2  psis=psi2*s1  IOPT=4 psis=psi2*s2
C
      implicit double precision (a-h, o-z)
      dimension wgt(n),yb(8,2)
      external s_scor,expsi,exgam

C to avoid warnings when compiling
      dummy = beta

      ans=exgam(sigm,alfa,dx)
      iopt=int(wgt(1))
      i=int(wgt(2))
      if(iopt.eq.1.or.iopt.eq.3)then
       jpsi=1
       jps0=int(yb(i,1))
       ps1=expsi(dx,jpsi,jps0,sigm,a11,a21,a22,c1,c2,b1,b2)
      else
       jpsi=2
       jps0=int(yb(i,2))
       ps2=expsi(dx,jpsi,jps0,sigm,a11,a21,a22,c1,c2,b1,b2)
      endif
        is=1
        S1=s_scor(dx,alfa,sigm,is, digam)
        is=2
        S2=s_scor(dx,alfa,sigm,is, digam)
      goto(10,20,30,40) IOPT
  10  s_psis=ps1*s1*ans
      return
  20  s_psis=ps2*s1*ans
      return
  30  s_psis=ps1*s2*ans
      return
  40  s_psis=ps2*s2*ans
      return
      END
C
C--------------------------------------------------------------
C
      DOUBLE PRECISION FUNCTION S_PSIPSI(Dx,WGT,N,EXPSI,EXGAM,
     1			alfa, sigm, a11, a21, a22,
     2			b1, b2, c1, c2, yb, digam, beta)
C
c     IOPT=1   PSIPSI=PSI1*PSI1     IOPT=3 PSI2*PSI1
C
      implicit double precision (a-h, o-z)
      external expsi,exgam
      dimension yb(8,2)
      dimension wgt(n)

C to avoid warnings
	  dummy = digam
	  dummy = beta

      x=dble(dx)
      ans=exgam(sigm,alfa,x)
      iopt=int(wgt(1))
      i=int(wgt(2))
      jpsi=1
      jps0=int(yb(i,1))
      ps1=expsi(x,jpsi,jps0,sigm,a11,a21,a22,c1,c2,b1,b2)
      jpsi=2
      jps0=int(yb(i,2))
      ps2=expsi(x,jpsi,jps0,sigm,a11,a21,a22,c1,c2,b1,b2)
      goto (10,20,30,40) iopt
  10  s_psipsi=ps1*ps1*dble(ans)
      return
  20  s_psipsi=ps1*ps2*dble(ans)
      return
  30  s_psipsi=ps2*ps1*dble(ans)
      return
  40  s_psipsi=ps2*ps2*dble(ans)
      return
      end
c
c----------------------------------------------------------------------
c
      SUBROUTINE S_BRKPTS(XLOWER,UPPER,xb,yb,ns,sigm,
     1 		a11,a21,a22,c1,c2,b1,b2)
      implicit double precision (a-h, o-z)
      DIMENSION XB(8),YB(8,2),Z0(8)
      external s_zscor
      DATA Z0/8*0.D0/
      xb(1)=-b1/A11+C1
      xb(2)= b1/A11+C1
      xb(3)=xlower
      xb(4)=upper
      call s_solvx(b2,1.D-3,nsol,xb(5),yb,A21,A22,C1,C2)
      ns=8
      if(xb(7).eq.0.D0) ns=6
      call s_srt2(xb,z0,8,1,ns)
      jup=ns
      jl0=0
      do 20 j=1,ns
      if(xb(j).le.xlower)then
        xb(j)=xlower
        jl0=j
      endif
      if(xb(j).ge.upper)then
        xb(j)=upper
        jup=MIN(jup,j)
      endif
  20  continue
      j0=0
      do 30 j=jl0,jup
      j0=j0+1
      xb(j0)=xb(j)
  30  continue
      ns=j0
      do 40 j=1,ns-1
      x=(xb(j)+xb(j+1))/2.d0
      iz=1
      zs1=s_zscor(x,1,SIGM,A11,A21,A22,C1,C2)
      iz=2
      zs2=s_zscor(x,2,SIGM,A11,A21,A22,C1,C2)
      tmp=dabs(zs1)
      yb(j,1)=0.d0
      yb(j,2)=0.d0
      if(tmp.gt.b1)yb(j,1)=zs1/tmp
      tmp=dabs(zs2)
      if(tmp.gt.b2)yb(j,2)=zs2/tmp
  40  continue
      return
      end
c
c=====================================================================
c

      SUBROUTINE S_VARGAM(MDT,ALPHA,SIGMA,TAB,TPAR,TIL,
     +                  M,Q,MI,V,VSIGA,VMOY,message)
      implicit double precision (a-h, o-z)
      double precision M(4), MI(4), MIT(4)
      dimension TAB(MDT,5),B(4),Q(4),TPAR(6),
     +     V(4),VSIGA(4),THETA(2),XB(8),YB(8,2)
      EXTERNAL S_GAMDIGAMA,S_GAMTRIGAM
C     
      MESSAGE=0
      IF (ALPHA.NE.0.D0.AND.SIGMA.NE.0.D0) THEN
        ALFA=ALPHA
        SIGM=SIGMA
        alpha1=tpar(3)
        alpha2=tpar(4)
        k=int(tpar(5))
        DELTA=tpar(6)        
        CALL S_LNTRP0(MDT,TAB,ALPHA,C1,C2,A11,A21,A22,
     1  		ALPHA1, ALPHA2, DELTA, K)
        b1=tpar(1)
        b2=tpar(2)
      ENDIF
      IF (ALFA.LE.0.D0.OR.SIGM.LE.0.D0) MESSAGE=1
      THETA(1)=ALFA
      THETA(2)=SIGM
      B(1)=SIGM
      B(2)=0.D0
      B(3)=0.D0
      B(4)=1.D0
      DIGAM=S_GAMDIGAMA(ALFA)
      TRIGM=S_GAMTRIGAM(ALFA)
      TMPSIG=SIGM
      SIGM=1.D0
      CALL S_LIMGAM(1.D0,ALFA,XLOWER,UPPER)
      CALL S_BRKPTS(XLOWER,UPPER,XB,YB,NS,SIGM,A11,A21,A22,C1,C2,
     1				b1,b2)
C
C                  M    =-int (dpsi/dtheta)=int(psi*s)
c                  Q    = int(psi * psi^T)
C
      CALL S_AUXVAS(TIL,m,q,alfa,sigm,a11,
     1 a21,a22,b1,b2,c1,c2,xb,yb,ns,digam,trigm)

C auxvas is causing some trouble... 


C
C  VARIANCE ASS :
c     V(tau,alfa) : V    =M^-1 * Q * M^-T
c     V(sigm,alfa): Vsiga=B * V * B
c
      CALL S_INVERS(M,MI)
      CALL S_TRNSPO(MI,MIT)
      CALL S_MULTIP(MI,Q,MIT,V)
      CALL S_MULTIP(B,V,B,VSIGA)
      CALL S_MULT2(THETA,VSIGA,THETA,VMOY)
      SIGM=TMPSIG
      RETURN
      END
c
c======================================================================
c Attention TRANSP existe dans SPLUS 
      SUBROUTINE S_TRNSPO(A,AT)
      implicit double precision (a-h, o-z)
      dimension A(4),AT(4)
      AT(1)=A(1)
      AT(4)=A(4)
      TMP=A(2)
      AT(2)=A(3)
      AT(3)=TMP
      RETURN
      END
C
C------------------------------------------------------------------
C
      SUBROUTINE S_MULTIP(A,B,C,D)
      implicit double precision (a-h, o-z)
      dimension B(4),C(4),D(4),A(4),X(4)
C
C     COMPUTE D=(A * B) * C
C
       X(1)=A(1)*B(1)+A(3)*B(2)
       X(2)=A(2)*B(1)+A(4)*B(2)
       X(3)=A(1)*B(3)+A(3)*B(4)
       X(4)=A(2)*B(3)+A(4)*B(4)
       D(1)=X(1)*C(1)+X(3)*C(2)
       D(2)=X(2)*C(1)+X(4)*C(2)
       D(3)=X(1)*C(3)+X(3)*C(4)
       D(4)=X(2)*C(3)+X(4)*C(4)
       RETURN
       END
C
C--------------------------------------------------------------------------
c
      SUBROUTINE S_MULT2(X,B,Y,D)
      implicit double precision (a-h, o-z)
      dimension X(2),Y(2),B(4)
C
C     COMPUTE D=X**T*(B * Y)
C
      D=X(1)*(B(1)*Y(1)+B(3)*Y(2))+X(2)*(B(2)*Y(1)+B(4)*Y(2))
      RETURN
      END
C
C--------------------------------------------------------------------------
C
      SUBROUTINE S_INVERS(A,AINV)
      implicit double precision (a-h, o-z)
      DOUBLE PRECISION DET
      dimension AINV(4),A(4)
C
C     COMPUTE AINV=A ^-1
C
       DET=A(1)*A(4)-A(2)*A(3)
       IF(DABS(DET).LT.1.D-6) THEN
        RETURN
       ENDIF
       AINV(1)=A(4)/DET
       AINV(4)=A(1)/DET
       AINV(2)=-A(2)/DET
       AINV(3)=-A(3)/DET
       RETURN
       END



C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_SRT2(A,B,N,K1,K2)
      implicit double precision(a-h, o-z)
      DIMENSION A(N),B(N)
      N1=K2-K1+1
      I=1
   10 I=I+I
      IF (I.LE.N1) GOTO 10
      M=I-1
   20 M=M/2
      IF (M.EQ.0) GOTO 90
      K=N1-M
      DO 40 J=1,K
      L=J
   50 IF (L.LT.1) GOTO 40
      LPM=L+M
      LPM1=LPM+K1-1
      L1=L+K1-1
      IF (A(LPM1).GE.A(L1)) GOTO 40
      X=A(LPM1)
      Y=B(LPM1)
      A(LPM1)=A(L1)
      B(LPM1)=B(L1)
      A(L1)=X
      B(L1)=Y
      L=L-M
      GOTO 50
   40 CONTINUE
      GOTO 20
   90 CONTINUE
      END
C
C----------------------------------------------------------------------
C-----------------------------------------------------------------------
C
      SUBROUTINE S_INTGRD(F,FARR,N,FEXT,GEXT,A,B,EPSABS,EPSREL,KEY,
     * 			 LIMIT,
     1           RESULT,ABSERR,NEVAL,IER,WORK,IWORK,alfa,sigm,
     2			 a11,a21,a22,b1,b2,c1,c2,YB,DIGAM,beta)
      implicit double precision(a-h, o-z)
      DOUBLE PRECISION A,ABSERR,B,EPSABS,EPSREL,F,RESULT,FEXT,WORK
      INTEGER IER,KEY,LAST,LIMIT,NEVAL,ALIST,BLIST,ELIST,RLIST

      DIMENSION FARR(N),WORK(4*LIMIT),IWORK(LIMIT),YB(8,2)

      EXTERNAL F,FEXT,GEXT
C
C         LIMIT IS THE MAXIMUM NUMBER OF SUBINTERVALS ALLOWED IN THE
C         SUBDIVISION PROCESS OF QAGE1D. TAKE CARE THAT LIMIT.GE.1.
C
C**** DATA LIMIT/500/
C
      ALIST=1
      BLIST=ALIST+LIMIT
      RLIST=BLIST+LIMIT
      ELIST=RLIST+LIMIT
      CALL S_QAGE1D(F,FARR,N,FEXT,GEXT,A,B,EPSABS,EPSREL,KEY,LIMIT,
     1     RESULT,ABSERR,NEVAL,IER,
     2     WORK,WORK(BLIST),WORK(RLIST),WORK(ELIST),IWORK,LAST,
     3     alfa,sigm,
     4     a11,a21,a22,b1,b2,c1,c2,yb,DIGAM,beta)

      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_QAGE1D(F,FARR,N,FEXT,GEXT,A,B,EPSABS,EPSREL,KEY,
     *  LIMIT,
     *  RESULT,ABSERR,NEVAL,IER,ALIST,BLIST,RLIST,ELIST,IORD,LAST,
     2  alfa,sigm,
     *  a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
	  implicit double precision(a-h, o-z)
      DOUBLE PRECISION A,ABSERR,ALIST,AREA,AREA1,AREA12,AREA2,
     *  AA1,AA2,B,
     *  BLIST,BB1,BB2,C,DABS,DEFABS,DEFAB1,DEFAB2,DMAX1,ELIST,EPMACH,
     *  EPSABS,EPSREL,ERRBND,ERRMAX,ERROR1,ERROR2,ERRO12,ERRSUM,F,OFLOW,
     *  RESABS,RESULT,RLIST,UFLOW,FEXT
      INTEGER IER,IORD,IROFF1,IROFF2,K,KEY,KEYF,LAST,LIMIT,MAXERR,NEVAL,
     *  NRMAX

      DIMENSION ALIST(LIMIT),BLIST(LIMIT),ELIST(LIMIT),IORD(LIMIT),
     *  RLIST(LIMIT),FARR(N),yb(8,2)

      EXTERNAL F,FEXT,GEXT
C
C            LIST OF MAJOR VARIABLES
C            -----------------------
C
C           ALIST     - LIST OF LEFT END POINTS OF ALL SUBINTERVALS
C                       CONSIDERED UP TO NOW
C           BLIST     - LIST OF RIGHT END POINTS OF ALL SUBINTERVALS
C                       CONSIDERED UP TO NOW
C           RLIST(I)  - APPROXIMATION TO THE INTEGRAL OVER
C                      (ALIST(I),BLIST(I))
C           ELIST(I)  - ERROR ESTIMATE APPLYING TO RLIST(I)
C           MAXERR    - POINTER TO THE INTERVAL WITH LARGEST
C                       ERROR ESTIMATE
C           ERRMAX    - ELIST(MAXERR)
C           AREA      - SUM OF THE INTEGRALS OVER THE SUBINTERVALS
C           ERRSUM    - SUM OF THE ERRORS OVER THE SUBINTERVALS
C           ERRBND    - REQUESTED ACCURACY MAX(EPSABS,EPSREL*
C                       ABS(RESULT))
C           *****1    - VARIABLE FOR THE LEFT SUBINTERVAL
C           *****2    - VARIABLE FOR THE RIGHT SUBINTERVAL
C           LAST      - INDEX FOR SUBDIVISION
C
C
C           MACHINE DEPENDENT CONSTANTS
C           ---------------------------
C
C           EPMACH  IS THE LARGEST RELATIVE SPACING.
C           UFLOW  IS THE SMALLEST POSITIVE MAGNITUDE.
C           OFLOW  IS THE LARGEST MAGNITUDE.
C
C***FIRST EXECUTABLE STATEMENTS
      CALL S_MACHD(7,EPMACH)
      CALL S_MACHD(4,UFLOW)
      CALL S_MACHD(6,OFLOW)
C
C           TEST ON VALIDITY OF PARAMETERS
C           ------------------------------
C
      NEVAL = 0
      LAST = 0
      RESULT = 0.0D+00
      ABSERR = 0.0D+00
      ALIST(1) = A
      BLIST(1) = B
      RLIST(1) = 0.0D+00
      ELIST(1) = 0.0D+00
      IORD(1) = 0
      IER=6
      IER = 0
C
C           FIRST APPROXIMATION TO THE INTEGRAL
C           -----------------------------------
C
      KEYF = KEY
      IF(KEY.LE.0) KEYF = 1
      IF(KEY.GE.7) KEYF = 6
      C = dble(KEYF)
      NEVAL = 0
      IF (KEYF.EQ.1)
     *  CALL S_Q1K15D(F,FARR,N,FEXT,GEXT,A,B,RESULT,ABSERR,DEFABS,
     *  RESABS,
     *   alfa,sigm,
     *	 a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
      LAST = 1
      RLIST(1) = RESULT
      ELIST(1) = ABSERR
      IORD(1) = 1
C
C           TEST ON ACCURACY.
C
      ERRBND = DMAX1(EPSABS,EPSREL*DABS(RESULT))
      IF(ABSERR.LE.5.0D+01*EPMACH*DEFABS.AND.ABSERR.GT.ERRBND) IER = 2
      IF(LIMIT.EQ.1) IER = 1
      IF(IER.NE.0.OR.(ABSERR.LE.ERRBND.AND.ABSERR.NE.RESABS)
     *  .OR.ABSERR.EQ.0.0D+00) GO TO 60
C
C           INITIALIZATION
C           --------------
C
C
      ERRMAX = ABSERR
      MAXERR = 1
      AREA = RESULT
      ERRSUM = ABSERR
      NRMAX = 1
      IROFF1 = 0
      IROFF2 = 0
C
C           MAIN DO-LOOP
C           ------------
C
      DO 30 LAST = 2,LIMIT
C
C           BISECT THE SUBINTERVAL WITH THE LARGEST ERROR ESTIMATE.
C
        AA1 = ALIST(MAXERR)
        BB1 = 5.0D-01*(ALIST(MAXERR)+BLIST(MAXERR))
        AA2 = BB1
        BB2 = BLIST(MAXERR)
        IF (KEYF.EQ.1)
     *  CALL S_Q1K15D(F,FARR,N,FEXT,GEXT,AA1,BB1,AREA1,ERROR1,
     *          RESABS,DEFAB1,
     *  		alfa,sigm,
     2			a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
        IF (KEYF.EQ.1)
     *  CALL S_Q1K15D(F,FARR,N,FEXT,GEXT,AA2,BB2,AREA2,ERROR2,
     *          RESABS,DEFAB2,
     *  		alfa,sigm,
     2			a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
        NEVAL = NEVAL+1
        AREA12 = AREA1+AREA2
        ERRO12 = ERROR1+ERROR2
        ERRSUM = ERRSUM+ERRO12-ERRMAX
        AREA = AREA+AREA12-RLIST(MAXERR)
        IF(DEFAB1.EQ.ERROR1.OR.DEFAB2.EQ.ERROR2) GO TO 5
        IF(DABS(RLIST(MAXERR)-AREA12).LE.1.0D-05*DABS(AREA12)
     *  .AND.ERRO12.GE.9.9D-01*ERRMAX) IROFF1 = IROFF1+1
        IF(LAST.GT.10.AND.ERRO12.GT.ERRMAX) IROFF2 = IROFF2+1
    5   RLIST(MAXERR) = AREA1
        RLIST(LAST) = AREA2
        ERRBND = DMAX1(EPSABS,EPSREL*DABS(AREA))
        IF(ERRSUM.LE.ERRBND) GO TO 8
C
C           TEST FOR ROUNDOFF ERROR AND EVENTUALLY SET ERROR FLAG.
C
        IF(IROFF1.GE.6.OR.IROFF2.GE.20) IER = 2
C
C           SET ERROR FLAG IN THE CASE THAT THE NUMBER OF
C           SUBINTERVALS EQUALS LIMIT.
C
        IF(LAST.EQ.LIMIT) IER = 1
C
C           SET ERROR FLAG IN THE CASE OF BAD INTEGRAND BEHAVIOUR
C           AT A POINT OF THE INTEGRATION RANGE.
C
        IF(DMAX1(DABS(AA1),DABS(BB2)).LE.(1.0D+00+C*1.0D+03*
     *  EPMACH)*(DABS(AA2)+1.0D+04*UFLOW)) IER = 3
C
C           APPEND THE NEWLY-CREATED INTERVALS TO THE LIST.
C
    8   IF(ERROR2.GT.ERROR1) GO TO 10
        ALIST(LAST) = AA2
        BLIST(MAXERR) = BB1
        BLIST(LAST) = BB2
        ELIST(MAXERR) = ERROR1
        ELIST(LAST) = ERROR2
        GO TO 20
   10   ALIST(MAXERR) = AA2
        ALIST(LAST) = AA1
        BLIST(LAST) = BB1
        RLIST(MAXERR) = AREA2
        RLIST(LAST) = AREA1
        ELIST(MAXERR) = ERROR2
        ELIST(LAST) = ERROR1
C
C           CALL SUBROUTINE QSORTD TO MAINTAIN THE DESCENDING ORDERING
C           IN THE LIST OF ERROR ESTIMATES AND SELECT THE SUBINTERVAL
C           WITH THE LARGEST ERROR ESTIMATE (TO BE BISECTED NEXT).
C
   20   CALL S_QSORTD(LIMIT,LAST,MAXERR,ERRMAX,ELIST,IORD,NRMAX)
C***JUMP OUT OF DO-LOOP
        IF(IER.NE.0.OR.ERRSUM.LE.ERRBND) GO TO 40
   30 CONTINUE
C
C           COMPUTE FINAL RESULT.
C           ---------------------
C
   40 RESULT = 0.0D+00
      DO 50 K=1,LAST
        RESULT = RESULT+RLIST(K)
   50 CONTINUE
      ABSERR = ERRSUM
   60 IF(KEYF.NE.1) NEVAL = (10*KEYF+1)*(2*NEVAL+1)
      IF(KEYF.EQ.1) NEVAL = 30*NEVAL+15
  999 CONTINUE
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_Q1K15D
     *  (F,FARR,N,FEXT,GEXT,A,B,RESULT,ABSERR,RESABS,RESASC,
     *  alfa,sigm,
     *	a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
	  implicit double precision(a-h, o-z)
      DOUBLE PRECISION A,ABSC,ABSERR,B,CENTR,DABS,DHLGTH,DMAX1,DMIN1,
     *  EPMACH,F,FC,FSUM,FVAL1,FVAL2,FV1,FV2,HLGTH,OFLOW,RESABS,RESASC,
     *  RESG,RESK,RESKH,RESULT,UFLOW,WG,WGK,XGK,FEXT
      INTEGER J,JTW,JTWM1
      EXTERNAL F,FEXT,GEXT

      DIMENSION FV1(7),FV2(7),WG(4),WGK(8),XGK(8),FARR(N)
	  dimension yb(8,2)

C           THE ABSCISSAE AND WEIGHTS ARE GIVEN FOR THE INTERVAL (-1,1).
C           BECAUSE OF SYMMETRY ONLY THE POSITIVE ABSCISSAE AND THEIR
C           CORRESPONDING WEIGHTS ARE GIVEN.
C
C           XGK    - ABSCISSAE OF THE 15-POINT KRONROD RULE
C                    XGK(2), XGK(4), ...  ABSCISSAE OF THE 7-POINT
C                    GAUSS RULE
C                    XGK(1), XGK(3), ...  ABSCISSAE WHICH ARE OPTIMALLY
C                    ADDED TO THE 7-POINT GAUSS RULE
C
C           WGK    - WEIGHTS OF THE 15-POINT KRONROD RULE
C
C           WG     - WEIGHTS OF THE 7-POINT GAUSS RULE
C
      DATA XGK(1),XGK(2),XGK(3),XGK(4),XGK(5),XGK(6),XGK(7),XGK(8)/
     *     9.914553711208126D-01,   9.491079123427585D-01,
     *     8.648644233597691D-01,   7.415311855993944D-01,
     *     5.860872354676911D-01,   4.058451513773972D-01,
     *     2.077849550078985D-01,   0.0D+00              /
      DATA WGK(1),WGK(2),WGK(3),WGK(4),WGK(5),WGK(6),WGK(7),WGK(8)/
     *     2.293532201052922D-02,   6.309209262997855D-02,
     *     1.047900103222502D-01,   1.406532597155259D-01,
     *     1.690047266392679D-01,   1.903505780647854D-01,
     *     2.044329400752989D-01,   2.094821410847278D-01/
      DATA WG(1),WG(2),WG(3),WG(4)/
     *     1.294849661688697D-01,   2.797053914892767D-01,
     *     3.818300505051189D-01,   4.179591836734694D-01/
C
C
C           LIST OF MAJOR VARIABLES
C           -----------------------
C
C           CENTR  - MID POINT OF THE INTERVAL
C           HLGTH  - HALF-LENGTH OF THE INTERVAL
C           ABSC   - ABSCISSA
C           FVAL*  - FUNCTION VALUE
C           RESG   - RESULT OF THE 7-POINT GAUSS FORMULA
C           RESK   - RESULT OF THE 15-POINT KRONROD FORMULA
C           RESKH  - APPROXIMATION TO THE MEAN VALUE OF F OVER (A,B),
C                    I.E. TO I/(B-A)
C
C           MACHINE DEPENDENT CONSTANTS
C           ---------------------------
C
C           EPMACH IS THE LARGEST RELATIVE SPACING.
C           UFLOW IS THE SMALLEST POSITIVE MAGNITUDE.
C           OFLOW IS THE LARGEST MAGNITUDE.
C
C***FIRST EXECUTABLE STATEMENTS
      CALL S_MACHD(7,EPMACH)
      CALL S_MACHD(4,UFLOW)
      CALL S_MACHD(6,OFLOW)

      CENTR = 5.0D-01*(A+B)
      HLGTH = 5.0D-01*(B-A)
      DHLGTH = DABS(HLGTH)
C
C           COMPUTE THE 15-POINT KRONROD APPROXIMATION TO
C           THE INTEGRAL, AND ESTIMATE THE ABSOLUTE ERROR.
C
      FC = F(CENTR,FARR,N,FEXT,GEXT,alfa,sigm,
     2			 a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
      RESG = FC*WG(4)
      RESK = FC*WGK(8)
      RESABS = DABS(RESK)
      DO 10 J=1,3
        JTW = J*2
        ABSC = HLGTH*XGK(JTW)
        FVAL1 = F(CENTR-ABSC,FARR,N,FEXT,GEXT,alfa,sigm,
     2			 a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
        FVAL2 = F(CENTR+ABSC,FARR,N,FEXT,GEXT,alfa,sigm,
     2			 a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
        FV1(JTW) = FVAL1
        FV2(JTW) = FVAL2
        FSUM = FVAL1+FVAL2
        RESG = RESG+WG(J)*FSUM
        RESK = RESK+WGK(JTW)*FSUM
        RESABS = RESABS+WGK(JTW)*(DABS(FVAL1)+DABS(FVAL2))
   10 CONTINUE
      DO 15 J = 1,4
        JTWM1 = J*2-1
        ABSC = HLGTH*XGK(JTWM1)
        FVAL1 = F(CENTR-ABSC,FARR,N,FEXT,GEXT,alfa,sigm,
     2			 a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
        FVAL2 = F(CENTR+ABSC,FARR,N,FEXT,GEXT,alfa,sigm,
     2			 a11,a21,a22,b1,b2,c1,c2,yb,digam,beta)
        FV1(JTWM1) = FVAL1
        FV2(JTWM1) = FVAL2
        FSUM = FVAL1+FVAL2
        RESK = RESK+WGK(JTWM1)*FSUM
        RESABS = RESABS+WGK(JTWM1)*(DABS(FVAL1)+DABS(FVAL2))
   15 CONTINUE
      RESKH = RESK*5.0D-01
      RESASC = WGK(8)*DABS(FC-RESKH)
      DO 20 J=1,7
        RESASC = RESASC+WGK(J)*(DABS(FV1(J)-RESKH)+DABS(FV2(J)-RESKH))
   20 CONTINUE
      RESULT = RESK*HLGTH
      RESABS = RESABS*DHLGTH
      RESASC = RESASC*DHLGTH
      ABSERR = DABS((RESK-RESG)*HLGTH)
      IF(RESASC.NE.0.0D+00.AND.ABSERR.NE.0.0D+00)
     *  ABSERR = RESASC*DMIN1(1.0D+00,(2.0D+02*ABSERR/RESASC)**1.5D+00)
      IF(RESABS.GT.UFLOW/(5.0D+01*EPMACH)) ABSERR = DMAX1
     *  ((EPMACH*5.0D+01)*RESABS,ABSERR)
      RETURN
      END
C
C-----------------------------------------------------------------------
C
      SUBROUTINE S_QSORTD(LIMIT,LAST,MAXERR,ERMAX,ELIST,IORD,NRMAX)
      DOUBLE PRECISION ELIST,ERMAX,ERRMAX,ERRMIN
      INTEGER I,IBEG,IDO,IORD,ISUCC,J,JBND,JUPBN,K,LAST,LIMIT,MAXERR,
     *  NRMAX
      DIMENSION ELIST(LAST),IORD(LAST)
C
C           CHECK WHETHER THE LIST CONTAINS MORE THAN
C           TWO ERROR ESTIMATES.
C
C***FIRST EXECUTABLE STATEMENT
      IF(LAST.GT.2) GO TO 10
      IORD(1) = 1
      IORD(2) = 2
      GO TO 90
C
C           THIS PART OF THE ROUTINE IS ONLY EXECUTED IF, DUE TO A
C           DIFFICULT INTEGRAND, SUBDIVISION INCREASED THE ERROR
C           ESTIMATE. IN THE NORMAL CASE THE INSERT PROCEDURE SHOULD
C           START AFTER THE NRMAX-TH LARGEST ERROR ESTIMATE.
C
   10 ERRMAX = ELIST(MAXERR)
      IF(NRMAX.EQ.1) GO TO 30
      IDO = NRMAX-1
      DO 20 I = 1,IDO
        ISUCC = IORD(NRMAX-1)
C***JUMP OUT OF DO-LOOP
        IF(ERRMAX.LE.ELIST(ISUCC)) GO TO 30
        IORD(NRMAX) = ISUCC
        NRMAX = NRMAX-1
   20    CONTINUE
C
C           COMPUTE THE NUMBER OF ELEMENTS IN THE LIST TO BE
C           MAINTAINED IN DESCENDING ORDER. THIS NUMBER
C           DEPENDS ON THE NUMBER OF SUBDIVISIONS STILL ALLOWED.
C
   30 JUPBN = LAST
      IF(LAST.GT.(LIMIT/2+2)) JUPBN = LIMIT+3-LAST
      ERRMIN = ELIST(LAST)
C
C           INSERT ERRMAX BY TRAVERSING THE LIST TOP-DOWN,
C           STARTING COMPARISON FROM THE ELEMENT ELIST(IORD(NRMAX+1)).
C
      JBND = JUPBN-1
      IBEG = NRMAX+1
      IF(IBEG.GT.JBND) GO TO 50
      DO 40 I=IBEG,JBND
        ISUCC = IORD(I)
C***JUMP OUT OF DO-LOOP
        IF(ERRMAX.GE.ELIST(ISUCC)) GO TO 60
        IORD(I-1) = ISUCC
   40 CONTINUE
   50 IORD(JBND) = MAXERR
      IORD(JUPBN) = LAST
      GO TO 90
C
C           INSERT ERRMIN BY TRAVERSING THE LIST BOTTOM-UP.
C
   60 IORD(I-1) = MAXERR
      K = JBND
      DO 70 J=I,JBND
        ISUCC = IORD(K)
C***JUMP OUT OF DO-LOOP
        IF(ERRMIN.LT.ELIST(ISUCC)) GO TO 80
        IORD(K+1) = ISUCC
        K = K-1
   70 CONTINUE
      IORD(I) = LAST
      GO TO 90
   80 IORD(K+1) = LAST
C
C           SET MAXERR AND ERMAX.
C
   90 MAXERR = IORD(NRMAX)
      ERMAX = ELIST(MAXERR)
      RETURN
      END
