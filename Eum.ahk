global SCREEN_CHANGE_DELAY := 2000 	 ;화면이 변경되는 시간
global SYSTEM_LOAD_DELAY := 1000 			;Loading등의 시간
global KEY_INPUT_DELAY := 500				 ;키보드 조작 시간
global MOUSE_INPUT_DELAY := 500 			;마우스 조작 시간
global SYSTEM_LINE_DELAY := 300 			;코드간 딜레이가 필요시

loginWindowsSetup()
{
	sleep, SCREEN_CHANGE_DELAY
	IfWinExist,Windows 보안  ;카메라 패스워드 입력 처음 qwerty0-, 두번째`12qwert, 세번째qa, 네번째 Enter, 다섯번째 패스워드 불일치로 종료
	{
		WinActivate,Windows 보안
		ControlSetText, Edit1, admin, Windows 보안
		sleep, SCREEN_CHANGE_DELAY
		ControlSetText, Edit2, qwerty0-, Windows 보안
		sleep, SCREEN_CHANGE_DELAY
		send,{enter}
		sleep, KEY_INPUT_DELAY
		IfWinExist,Windows 보안
		{
			send,`12qwert
			sleep, SCREEN_CHANGE_DELAY
			send,{enter}
			sleep, KEY_INPUT_DELAY
		}
		IfWinExist,Windows 보안
		{
			send,qa
			sleep, KEY_INPUT_DELAY
			send, {enter}
			sleep, 1000
		}
		IfWinExist,Windows 보안
		{
			send,{enter}
			sleep, 1000
		}
		IfWinExist,Windows 보안
		{
			controlsend, Edit1, Password 불일치로 종료,제목 없음 - 메모장
			ExitApp
		}
	}
	else
	{
	}
	return
}

loginInit()
{
	IfWinExist,Login ;카메라 패스워드 입력 처음 qwerty0-, 두번째`12qwert, 세번째 qa, 네번째Enter 그래도 못찾으면 INIT종료
	{
		sleep, SCREEN_CHANGE_DELAY
		send,qwerty0-
		sleep, SYSTEM_LINE_DELAY
		send,{enter}
		sleep, KEY_INPUT_DELAY
		IfWinExist,Login
		{
			send,`12qwert
			sleep, SYSTEM_LINE_DELAY
			send,{enter}
			sleep, KEY_INPUT_DELAY
		}
		IfWinExist,Login
		{
			send,qa
		}
		IfWinExist,Login
		{
			send,{enter}
		}
	}
}

searchCameraInit() ;카메라 검색
{
	IfwinnotExist,IDIS Discovery
	{
		run, IDIS Discovery
		sleep,3000
		IfWinExist,Language Option...
		{
			WinActivate,Language Option... ;언어선택 미국!
			sleep, KEY_INPUT_DELAY
			mouseclick, left,255,110
			sleep, KEY_INPUT_DELAY
			mouseclick,left,121,402
		}
	}
	else
	{
	}
	sleep,5000
	WinActivate,IDIS Discovery 
	WinMaximize,IDIS Discovery
	a=0
	while(a<3) ;카메라 검색 및 카메라가 안뜰경우, 카메라 2회 더 검색
	{
		if  temText =
		{
			sleep, SCREEN_CHANGE_DELAY
			mouseclick,left,80,50 ;loop up클릭
			sleep, SYSTEM_LINE_DELAY
			send,{down}
			sleep, SYSTEM_LINE_DELAY
			send,{enter} ;LAN스캔 선택
			
			mouseclick,left,80,50 ;loop up클릭
			send,{down 2}
			sleep, SCREEN_CHANGE_DELAY
			send,{enter}
			sleep, SCREEN_CHANGE_DELAY
			send,%IpAddress% ;Ipaddress받아오기
			sleep, KEY_INPUT_DELAY
			send,{enter}
			sleep,10000
			WinActivate,IDIS Discovery
			mousemove,908,134 ;IPAddress하위탭으로 이동하여 OCR확인
			sleep, KEY_INPUT_DELAY
			readTextOCR(150,10)
			temText =%ocrText%
			if a=2
			{
				winKill, IDIS Discovery
				;gosub A <-검색 실패 시 Soft reset다음 TC로 이동필요
				;return
			}
			a++
		}
		else
		{
			break
		}
	}
	return
}

initializePasswordInit() ;카메라 검색 및 패스워드입력
{
	mouseclick,right, 908,134 ;검색된 카메라 우클릭
	sleep, KEY_INPUT_DELAY
	send,{down} ;IP주소 셋업
	sleep, SYSTEM_LINE_DELAY
	send,{enter} ;IP주소 셋업 선택
	sleep,1500
	IfWinExist,Password initialization ;패스워드 초기화창이 뜨면
	{
		sleep, KEY_INPUT_DELAY
		ControlSend,Edit4,qwerty0-,Password initialization ;패스워드 입력
		sleep, KEY_INPUT_DELAY
		ControlSend,Edit5,qwerty0-,Password initialization ;패스워드 재확인에 입력
		sleep, KEY_INPUT_DELAY
		controlsend,Button1,{space},Password initialization ;이메일 Non-check
		sleep, SCREEN_CHANGE_DELAY
		IfWinExist,INIT
		{
			send,{space} ;이메일 non-check시 팝업창 종료
		}
		ControlSend,Edit7,01012345678,Password initialization ;SMS입력(KOR든 다른 OEM이든 상관없이 입력되지만 다른 OEM은 무시 됨)
		sleep, KEY_INPUT_DELAY
		Controlsend,Button3,{enter},Password initialization ;확인 누름
	}
	else
	{
	}
	IfWinExist,Login ;패스워드가 있는 카메라의 경우, LoGIN창이 뜨면
	{
		sleep, KEY_INPUT_DELAY
		loginInit()
	}
	
	WinWait,IP Address Setup ;IP주소창이 뜨는 것을 기다림
	sleep, KEY_INPUT_DELAY
	WinClose,IP Address Setup
	WinWaitClose,IP Address Setup ;IP주소창 종료 후, 종료되기까지 기다림
	sleep, SCREEN_CHANGE_DELAY
	WinMinimize,IDIS Discovery
	return
}


confirmResetApi()
{
	command = action=dateTime&mode=1 ;타임존 초기화되었는지 확인
	run,http://%ipAddress%:%Port%/cgi-bin/webSetup.cgi?%command%
	loginWindowsSetup()
	sleep, SCREEN_CHANGE_DELAY
	send,^a
	sleep, KEY_INPUT_DELAY
	send,^c
	sleep, SYSTEM_LINE_DELAY
	parsingInfo("timeZone=",5)
	if  (parsingText = "Easte" or parsingText ="Seoul" or parsingText = "Tokyo" or  parsingText = "Green" ) 		;Load default에는 Timezone이 초기화안되는게 성공이고 Factory reset때는 초기화되는게 성공
	{
		timeZoneIndex := 0
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% TimeZone PASS`n ,Cam_Test_log.txt 			
	}
	else
	{
		timeZoneIndex := 1
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% TimeZone FAIL`n ,Cam_Test_log.txt 								
	}
	sleep, SCREEN_CHANGE_DELAY

	send,{tab}
	sleep, KEY_INPUT_DELAY
	command = ?action=eventMotion&mode=1 	;Motion초기화되었는지 확인
	SendInput,http://%ipAddress%:%Port%/cgi-bin/webSetup.cgi?%command%
	sleep, SCREEN_CHANGE_DELAY
	send,{enter}
	sleep, SCREEN_CHANGE_DELAY
	send,^a
	sleep, KEY_INPUT_DELAY
	send,^c
	sleep, SYSTEM_LINE_DELAY
	parsingInfo("actionEmail=",3)
	emailInfo = %parsingText%
	parsingInfo("actionCallback=",3)
	callbackInfo = %parsingText%
	allInfo = %emailInfo%%callbackInfo%
	if  allInfo = offoff
	{
		motionIndex := 0
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% MotionEvent PASS`n  ,Cam_Test_log.txt
	}
	else
	{
		motionIndex := 1
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% MotionEvent FAIL`n  ,Cam_Test_log.txt 									;Load default시 초기화될 경우, 실패처리로 문구 남김
	}
	sleep, SCREEN_CHANGE_DELAY

	send,{tab}
	sleep, KEY_INPUT_DELAY
	command = action=videoWb&mode=1 ;White balance초기화되었는지 확인
	SendInput,http://%ipAddress%:%Port%/cgi-bin/webSetup.cgi?%command%
	sleep, SCREEN_CHANGE_DELAY
	send,{enter}
	sleep, SCREEN_CHANGE_DELAY
	send,^a
	sleep, SYSTEM_LINE_DELAY
	send,^c
	sleep, SYSTEM_LINE_DELAY
	parsingInfo("wbMode=",4)
	if  ParsingText = auto
	{
		wbIndex := 0
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% White Balance PASS`n  ,Cam_Test_log.txt
	}
	else
	{
		wbIndex := 1
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% White Balance FAIL`n ,Cam_Test_log.txt 									;Load default시 초기화될 경우, 실패처리로 문구 남김
	}
	sleep, SCREEN_CHANGE_DELAY

/*
	defaultWtihoutNetwork = %timeZoneIndex%%motionIndex%%wbIndex%
	if defaultWtihoutNetwork = 000
	{
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% 네트워크 제외 Load Default / Factory Reset = Network제외항목 설정 초기화 PASS `n, Cam_Test_log.txt 									;Load default시 초기화될 경우, 실패처리로 문구 남김
	}
	else
	{
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% 네트워크 제외 Load Default / Factory Reset = Network제외항목 설정 초기화 FAIL `n, Cam_Test_log.txt
	}
*/

	send,{tab}
	sleep, KEY_INPUT_DELAY
	command = action=networkPort&mode=1 ;RTSP포트 변경되었는지 확인
	SendInput,http://%ipAddress%:%Port%/cgi-bin/webSetup.cgi?%command%
	sleep, SCREEN_CHANGE_DELAY
	send,{enter}
	sleep, SCREEN_CHANGE_DELAY
	send,^a
	sleep, SYSTEM_LINE_DELAY
	send,^c
	sleep, SYSTEM_LINE_DELAY
	parsingInfo("rtspPort=",5)
	if  parsingText = 65535
	{
		rtspIndex := 0
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% RTSP PASS`n ,Cam_Test_log.txt 
	}
	else
	{
		rtspIndex := 1
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% RTSP FAIL`n ,Cam_Test_log.txt 		 ;네트워크 제외 Load default이므로 초기화될 경우 실패 처리로 문구 남김
	}
	sleep, SCREEN_CHANGE_DELAY

	send,{tab}
	sleep, KEY_INPUT_DELAY
	command = action=networkDDNS&mode=1 ;FEN변경되었는지 확인
	SendInput,http://%ipAddress%:%Port%/cgi-bin/webSetup.cgi?%command%
	sleep, SCREEN_CHANGE_DELAY
	send,{enter}
	sleep, SCREEN_CHANGE_DELAY
	send,^a
	sleep, SYSTEM_LINE_DELAY
	send,^c
	sleep, SYSTEM_LINE_DELAY
	parsingInfo("cameraName=",20)
	if  parsingText = %fenIp%Before
	{
		fenIndex := 0
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% FEN PASS`n ,Cam_Test_log.txt 
	}
	else
	{
		fenIndex := 1
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend,%TimeString% FEN FAIL`n ,Cam_Test_log.txt 	 ;FEN은 초기화될 경우 실패 처리로 문구 남김
	}
	sleep, SCREEN_CHANGE_DELAY
	
/*
	defaultNetwork = %rtspIndex%%fenIndex%
	if defaultNetwork = 00
	{
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% 네트워크 제외 Load Default / Factory Reset = Network항목 초기화 PASS  ,Cam_Test_log.txt
	}
	else
	{
		FormatTime, TimeString, dddd MMMM d, yyyy MM/dd HH:mm:ss
		FileAppend, %TimeString% 네트워크 제외 Load Default / Factory Reset = Network항목 초기화 FAIL  ,Cam_Test_log.txt
	}
	*/
	finalDecision =  %timeZoneIndex%%motionIndex%%wbIndex%%rtspIndex%%fenIndex%
	return
}