	
	SUBROUTINE POCKET_ANALYST
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
	PARAMETER (MXPR=100000,MXAA=1000,MXCH=10)
	CHARACTER CHN*1,AAN*3,PRN*3
      COMMON /PROTEIN/ CHN(MXCH),
	*                 AAN(MXCH,MXAA),IAS(MXCH,MXAA),IAE(MXCH,MXAA),
	*                 AAFX(MXCH,MXAA),AAFY(MXCH,MXAA),AAFZ(MXCH,MXAA),
	*                 PRN(MXPR),PRX(MXPR),PRY(MXPR),PRZ(MXPR),
	*                 IFOCH,IFOAA(MXCH)
	PARAMETER (MXHAT=100,MXMOL=1000)
	CHARACTER*3 HAMN,HATN
	COMMON /HETATM/ NMOL,HAMN(MXMOL),IAM(MXMOL),
	*                HAFX(MXMOL),HAFY(MXMOL),HAFZ(MXMOL),
	*                HATN(MXMOL,MXHAT),HATX(MXMOL,MXHAT),
     *                HATY(MXMOL,MXHAT),HATZ(MXMOL,MXHAT)

	CALL BOX_ESTABLISH
	CALL INPUT_POCKET
	CALL FIND_POCKET
	CALL OUTPUT_POCKET

	WRITE(*,*) '              Define pockets completed...'

	RETURN
	END

	SUBROUTINE BOX_ESTABLISH
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
	PARAMETER (MXPR=100000,MXAA=1000,MXCH=10)
	CHARACTER CHN*1,AAN*3,PRN*3
      COMMON /PROTEIN/ CHN(MXCH),
	*                 AAN(MXCH,MXAA),IAS(MXCH,MXAA),IAE(MXCH,MXAA),
	*                 AAFX(MXCH,MXAA),AAFY(MXCH,MXAA),AAFZ(MXCH,MXAA),
	*                 PRN(MXPR),PRX(MXPR),PRY(MXPR),PRZ(MXPR),
	*                 IFOCH,IFOAA(MXCH)
	COMMON /PROTBOX/ BMINX,BMINY,BMINZ,BDELX,BDELY,BDELZ

	BMINX=PRX(1)
	BMINY=PRY(1)
	BMINZ=PRZ(1)
	BDELX=PRX(1)
	BDELY=PRY(1)
	BDELZ=PRZ(1)
	DO I=1,IAE(IFOCH,IFOAA(IFOCH))
	 IF (PRX(I).LT.BMINX) THEN
	  BMINX=PRX(I)
	 ENDIF
	 IF (PRY(I).LT.BMINY) THEN
	  BMINY=PRY(I)
	 ENDIF
	 IF (PRZ(I).LT.BMINZ) THEN
	  BMINZ=PRZ(I)
	 ENDIF
	 IF (PRX(I).GT.BDELX) THEN
	  BDELX=PRX(I)
	 ENDIF
	 IF (PRY(I).GT.BDELY) THEN
	  BDELY=PRY(I)
	 ENDIF
	 IF (PRZ(I).GT.BDELZ) THEN
	  BDELZ=PRZ(I)
	 ENDIF
	END DO
	BDELX=BDELX-BMINX
	BDELY=BDELY-BMINY
	BDELZ=BDELZ-BMINZ

	RETURN
	END

	SUBROUTINE INPUT_POCKET
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
	COMMON /INPPOCKET/ NPARTX,NPARTY,NPARTZ,DISMIN,DISMAX,PVLIM,PSPACE
	NAMELIST/INPPOCKET/NPARTX,NPARTY,NPARTZ,DISMIN,DISMAX,PVLIM,PSPACE

	OPEN(UNIT=13, FILE='Pocket/Pocket.inp', STATUS='UNKNOWN')
      READ (13, NML=INPPOCKET)
	CLOSE(13)

	RETURN
	END

	SUBROUTINE PR_ANALYST(SX,SY,SZ)
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
	PARAMETER (MXPR=100000,MXAA=1000,MXCH=10)
	CHARACTER CHN*1,AAN*3,PRN*3
      COMMON /PROTEIN/ CHN(MXCH),
	*                 AAN(MXCH,MXAA),IAS(MXCH,MXAA),IAE(MXCH,MXAA),
	*                 AAFX(MXCH,MXAA),AAFY(MXCH,MXAA),AAFZ(MXCH,MXAA),
	*                 PRN(MXPR),PRX(MXPR),PRY(MXPR),PRZ(MXPR),
	*                 IFOCH,IFOAA(MXCH)
	COMMON /INPPOCKET/ NPARTX,NPARTY,NPARTZ,DISMIN,DISMAX,PVLIM,PSPACE
	COMMON /PRADIS/ NDIS,DIS(MXAA*MXCH),IDC(MXAA*MXCH),IDR(MXAA*MXCH)
	COMMON /AADENS/	NLIST,LIST(MXAA*MXCH)
	COMMON /POCVEC/ VPL,FPX,FPY,FPZ

	NDIS=0
	DO I=1,IFOCH							  !///////////////////////////////
	 DO J=1,IFOAA(I)						  !// Xac dinh khoang cach toi
	  NDIS=NDIS+1							  !// tat ca cac AA 
	  DIS(NDIS)=SQRT((AAFX(I,J)-SX)**2+		  !// trong mach PROTEIN
	*                 (AAFY(I,J)-SY)**2+		  !// Trong do:              
     *                 (AAFZ(I,J)-SZ)**2)		  !//  NDIS - So khoang cach 
	  IDC(NDIS)=I							  !// 	DIS	- Khoang cach    
	  IDR(NDIS)=J							  !// 	IDC	- ID cua CHAIN   
	 END DO									  !// 	IDR	- ID cua AA      
	END DO									  !///////////////////////////////

	NLIST=0
	DO I=1,NDIS								  !\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	 IF (DIS(I).LT.DISMIN) THEN				  !\\$ Neu DIST nho hon gh duoi 
	  NLIST=-1								  !\\$	Cho gia tri NLIST=-1
	  GOTO 100								  !\\$	Thoat khoi khu vuc xu li
	 ELSE									  !\\$ Neu khong
	  IF (DIS(I).LT.DISMAX) THEN			  !\\$	Neu DIST nho hon gh tren 
	   NLIST=NLIST+1						  !\\$	 Tang NLIST
	   LIST(NLIST)=I						  !\\$	 Xd gia tri LIST
	  ENDIF									  !\\$	***
	 ENDIF									  !\\$ ***
	END DO									  !\\$***
100	CONTINUE								  !\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	IF (NLIST.EQ.-1.OR.NLIST.EQ.0) THEN
	 GOTO 200
	ENDIF
	 FPX=0  
	 FPY=0  
	 FPZ=0
	DO I=1,NLIST							  
	 FPX=FPX+AAFX(IDC(LIST(I)),IDR(LIST(I)))  
	 FPY=FPY+AAFY(IDC(LIST(I)),IDR(LIST(I)))  
	 FPZ=FPZ+AAFZ(IDC(LIST(I)),IDR(LIST(I)))  
	END DO									  
	FPX=FPX/NLIST   						  
	FPY=FPY/NLIST   						 
	FPZ=FPZ/NLIST   						  
	VPL=SQRT((FPX-SX)**2+(FPY-SY)**2+(FPZ-SZ)**2)
200	CONTINUE

	RETURN
	END

	SUBROUTINE FIND_POCKET
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
	COMMON /INPPOCKET/ NPARTX,NPARTY,NPARTZ,DISMIN,DISMAX,PVLIM,PSPACE
	COMMON /PROTBOX/ BMINX,BMINY,BMINZ,BDELX,BDELY,BDELZ
	PARAMETER (MXPR=100000,MXAA=1000,MXCH=10)
	COMMON /AADENS/	NLIST,LIST(MXAA*MXCH)
	COMMON /POCVEC/ VPL,FPX,FPY,FPZ
	COMMON /POCKET/ NPK,PKX(1000),PKY(1000),PKZ(1000),PVL(1000)
	DIMENSION ARX(100000),ARY(100000),ARZ(100000)
	LOGICAL FINISH

	NAR=0
	DO I=1,NPARTZ
	 SZ=BMINZ+I*(BDELZ/NPARTZ)
	write(*,*) I
	 DO J=1,NPARTY
	  SY=BMINY+J*(BDELY/NPARTY)
	  DO K=1,NPARTX
	   SX=BMINX+K*(BDELX/NPARTX)
	   CALL PR_ANALYST(SX,SY,SZ)
	   IF (NLIST.EQ.-1.OR.NLIST.EQ.0) THEN
	    GOTO 100
	   ENDIF
	   IF (VPL.LT.PVLIM) THEN
	    NAR=NAR+1
	    ARX(NAR)=FPX
	    ARY(NAR)=FPY
	    ARZ(NAR)=FPZ
	write(*,'(I5,4F14.5)') NAR,FPX,FPY,FPZ,VPL
	   ENDIF
100	   CONTINUE
	  END DO
	 END DO
	END DO

	DO WHILE(.NOT.FINISH)
	NPK=0
	DO I=1,NAR
	 CALL PR_ANALYST(ARX(I),ARY(I),ARZ(I))
	 IF (NLIST.EQ.-1.OR.NLIST.EQ.0) THEN
	  GOTO 300
	 ENDIF
	 IF (VPL.LT.PVLIM) THEN
	  IF (NPK.EQ.0) THEN
	   NPK=NPK+1
	   PKX(1)=FPX
	   PKY(1)=FPY
	   PKZ(1)=FPZ
	   PVL(1)=VPL
	  ELSE
	    DO J=1,NPK
	     RPK=SQRT((PKX(J)-FPX)**2+(PKY(J)-FPY)**2+(PKZ(J)-FPZ)**2)
		 IF (RPK.LE.PSPACE) THEN
		  IF (RPK.LE.PSPACE.AND.VPL.LT.PVL(J)) THEN
	       PKX(J)=FPX
	       PKY(J)=FPY
	       PKZ(J)=FPZ
		   PVL(J)=VPL		   
		  ENDIF
		  GOTO 200
		 ENDIF
	    END DO
	      NPK=NPK+1
	      PKX(NPK)=FPX
	      PKY(NPK)=FPY
	      PKZ(NPK)=FPZ
		  PVL(NPK)=VPL
200	    CONTINUE
	   ENDIF
	  ENDIF
300	   CONTINUE
	END DO

	FINISH=.TRUE.
	NAR=NPK
	DO I=1,NPK
	 ARX(I)=PKX(I)
	 ARY(I)=PKY(I)
	 ARZ(I)=PKZ(I)
	 IF (PVL(I).GT.0) THEN
	  FINISH=.FALSE.
	 ENDIF
	write(*,'(I5,4F14.4)') I,PKX(I),PKY(I),PKZ(I),PVL(I)
	END DO
	write(*,*)
	END DO
	RETURN
	END

	SUBROUTINE OUTPUT_POCKET
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
	PARAMETER (MXPR=100000,MXAA=1000,MXCH=10)
	CHARACTER CHN*1,AAN*3,PRN*3
      COMMON /PROTEIN/ CHN(MXCH),
	*                 AAN(MXCH,MXAA),IAS(MXCH,MXAA),IAE(MXCH,MXAA),
	*                 AAFX(MXCH,MXAA),AAFY(MXCH,MXAA),AAFZ(MXCH,MXAA),
	*                 PRN(MXPR),PRX(MXPR),PRY(MXPR),PRZ(MXPR),
	*                 IFOCH,IFOAA(MXCH)
	COMMON /POCKET/ NPK,PKX(1000),PKY(1000),PKZ(1000),PVL(1000)
	COMMON /PRADIS/ NDIS,DIS(MXAA*MXCH),IDC(MXAA*MXCH),IDR(MXAA*MXCH)
	COMMON /AADENS/	NLIST,LIST(MXAA*MXCH)

	OPEN(UNIT=21, FILE='Pocket/Relation/Pocket.out', STATUS='UNKNOWN')
	WRITE(21,'(I4)') NPK
	WRITE(21,*) 'POCKET DETECTED'
	DO I=1,NPK
	 WRITE(21,'(A5,I4,F12.5,2F10.5)') '     ',I,PKX(I),PKY(I),PKZ(I)  
	END DO
	CLOSE(21)

	OPEN(UNIT=22, FILE='Pocket/Relation/Pocket.inf', STATUS='UNKNOWN')
	DO I=1,NPK
	 WRITE(22,'(A7,I4,F18.3,2F10.3)') 'POCKET ',I,PKX(I),PKY(I),PKZ(I)
	 CALL PR_ANALYST(PKX(I),PKY(I),PKZ(I))
	 DO J=1,NLIST
	  WRITE(22,'(A5,A3,I4,F18.3)') AAN(IDC(LIST(J)),IDR(LIST(J))),
	*             CHN(IDC(LIST(J))),IDR(LIST(J)),DIS(LIST(J))
	 END DO
	 WRITE(22,*) '          ********************          '	  
	END DO
	CLOSE(22)

	RETURN
	END

	SUBROUTINE POCNOT_ANALYST
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
	PARAMETER (MXPR=100000,MXAA=1000,MXCH=10)
	CHARACTER CHN*1,AAN*3,PRN*3
      COMMON /PROTEIN/ CHN(MXCH),
	*                 AAN(MXCH,MXAA),IAS(MXCH,MXAA),IAE(MXCH,MXAA),
	*                 AAFX(MXCH,MXAA),AAFY(MXCH,MXAA),AAFZ(MXCH,MXAA),
	*                 PRN(MXPR),PRX(MXPR),PRY(MXPR),PRZ(MXPR),
	*                 IFOCH,IFOAA(MXCH)
	COMMON /POCKET/ NPK,PKX(1000),PKY(1000),PKZ(1000),PVL(1000)
	COMMON /PRADIS/ NDIS,DIS(MXAA*MXCH),IDC(MXAA*MXCH),IDR(MXAA*MXCH)
	COMMON /AADENS/	NLIST,LIST(MXAA*MXCH)

	CALL BOX_ESTABLISH
	CALL INPUT_POCKET

	OPEN(UNIT=21, FILE='Pocket/Relation/Pocket.out', STATUS='UNKNOWN')
	READ(21,*) NPK
	READ(21,*)
	DO I=1,NPK
	 READ(21,*) J,PKX(I),PKY(I),PKZ(I)  
	END DO
	CLOSE(21)

	OPEN(UNIT=22, FILE='Pocket/Relation/Pocket.inf', STATUS='UNKNOWN')
	DO I=1,NPK
	 WRITE(22,'(A7,I4,F18.3,2F10.3)') 'POCKET ',I,PKX(I),PKY(I),PKZ(I)
	 CALL PR_ANALYST(PKX(I),PKY(I),PKZ(I))
	 DO J=1,NLIST
	  WRITE(22,'(A5,A3,I4,F18.3)') AAN(IDC(LIST(J)),IDR(LIST(J))),
	*             CHN(IDC(LIST(J))),IDR(LIST(J)),DIS(LIST(J))
	 END DO
	 WRITE(22,*) '          ********************          '	  
	END DO
	CLOSE(22)

	WRITE(*,*) '              Define pockets completed...'

	RETURN
	END

	SUBROUTINE POCKET_PDB
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
	COMMON /POCKET/ NPK,PKX(1000),PKY(1000),PKZ(1000),PVL(1000)

	OPEN(UNIT=22, FILE='Pocket/POCK.pdb', STATUS='UNKNOWN')
	N=0
	L=1
	DO I=1,NPK
		N=N+1
	    write(22,'(A6,I5,A5,A4,A2,I4,A4,3F8.3)')
	+    'HETATM',N,'CEN','POC','  ',L,'    ',
     +     PKX(I),PKY(I),PKZ(I)  
	END DO
	CLOSE(22)

	RETURN
	END