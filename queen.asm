.386
IDEAL
MODEL small
STACK 256d
; have fun from Shmulick

; --------------------------small pic
MAX_BMP_WIDTH = 320
MAX_BMP_HEIGHT = 200
SMALL_BMP_HEIGHT = 320
SMALL_BMP_WIDTH = 200
;--------------------------
DATASEG
; Your variables here
;----------------pic staff
filename db 'start.bmp',0
filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsg db 'Error', 13, 10,'$'
;----------------------small pic
OneBmpLine  db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
   
    ScreenLineMax   db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
    ;BMP File data
    FileHandle1 dw ?
    Header1         db 54 dup(0)
    Palette1    db 400h dup (0)
    SmallPicName db 'line.bmp',0
    BmpFileErrorMsg     db 'Error At Opening Bmp File .', 0dh, 0ah,'$'
    ErrorFile           db 0
    BB db "BB..",'$'
    BmpLeft dw ?
    BmpTop dw ?
    BmpColSize dw ?
    BmpRowSize dw ?
;----------------------my variables
counter1 db 8
counter2 db 8
counterMove dw 0
temp db 48,'$'
x dw 50
y dw 20
width1 dw 20
height1 dw 20
boardArray db 0,0,0,0,0,0,0,0 ;0c80-0c88 in debugger
color db 1 ;(4,5,6,7) is a (red,purple,green,white color...
resultNumber db ' the result number is:','$'
winNum db 48,13,10,'$'
rowSave dw 0
cxSave dw 0
nextResult db 'prass x for next result or q for quit',13,10,'$'

printStart    db '                                    **                           ',13,10
              db '                                    **                           ',13,10
              db '                              **************                     ',13,10
              db '                                    **                           ',13,10
              db '                                    **                           ',13,10
              db '                      *************    *************             ',13,10
              db '                    **********************************           ',13,10
              db '                    ****        **********        ****           ',13,10
              db '              **********                          **********     ',13,10
              db '            ******  ****  8 Queens Challenge !!   ****  ******   ',13,10
              db '            ****                **********                ****   ',13,10
              db '            ****      ****        ******        ****      ****   ',13,10
              db '            ******    ****        ******        ****    ******   ',13,10
              db '            ********    **        ******        **    ********   ',13,10
              db '              ********    **      ******      **    ********     ',13,10
              db '                ******      **    ******    **      ******       ',13,10
              db '                  ******    ****  ******  ****    ******         ',13,10
              db '                  **************  ******  **************         ',13,10
              db '                    **********************************           ',13,10
              db '                    ****  ****  ****  ****  ****  ****           ',13,10
              db '                  **************************************         ',13,10
              db '                  **************************************         ',13,10                                        
              db ' ',13,10
              db ' ',13,10,'$'

prasskey db '                     Please prass any key to continue',13,10,'$'
;--------------------------
; Your code here
;----------------------------
CODESEG
;---------------------------
proc startGame

push ax
push bx
push cx
push dx

    mov dx, offset printStart
    mov ah,9
    int 21h
    
    mov dx, offset prasskey
    mov ah,9
    int 21h
    
    ; Wait for key press
    mov ah,00h
    int 16h
    
    call resetScreen
    
pop dx
pop cx
pop bx
pop ax

ret
endp startGame
;--------------------------------------
proc resetScreen

push ax
push bx
push cx
push dx

    mov ax,0600h    ;To reset the screen al-00 ah-06
    mov bh,0        ;color for backround
    int 10h
    
pop dx
pop cx
pop bx
pop ax

ret
endp resetScreen
;---------------------------------------
;squre 
;stat: ok
proc squre

push ax
push bx
push cx
push dx

    mov [width1],20;not alwas need
    mov [height1],20;not alwas need 
    loppOfPisels:

    push [width1]
    call line

    sub [y],1
    sub [x],20
    sub [height1],1
    mov cx,[height1]
    loop loppOfPisels
    
pop dx
pop cx
pop bx
pop ax

ret
endp squre
;-------------------------------------
;stat: need to add staff
proc chessBoard

push ax
push bx
push cx
push dx

    ;turns to graphic mode
        mov ax, 13h
        int 10h

    mov [counter1],8;col num
    loopForRow:

    add [x],20 ;height1
    add [y],152 ;height1*8-8

    mov [counter2],8;row num
    loopForLine:

    cmp [counter2],8;if first in row
    je notChangeColor ;dont change Color on first squre in row

    cmp [color],1; if blue color
    jne ChangeColor ; change Color 
    mov [color],15 ; change Color to white
    jmp notChangeColor
     
    ChangeColor:
    mov [color],1;blue color
    notChangeColor:
    call squre
    sub [counter2],1
    jnz loopForLine

    sub [counter1],1
    jnz loopForRow

    mov [x],50 
    mov [y],20 

pop dx
pop cx
pop bx
pop ax

ret
endp chessBoard
;-----------------------------------
;stat: ok
proc my_pixel
push ax
push bx
push cx
push dx

; print a dot
    mov bh,0h ; page... dont have to know!
    mov cx,[x] ; x place
    mov dx,[y] ; y place
    mov al,[color] ; color
    
; prints a pixel color from al, x place from cx, y place from dx    
    mov ah,0ch
    int 10h

pop dx
pop cx
pop bx
pop ax

ret
endp my_pixel
;-----------------------------------------

bpWidth1 equ [bp+4]
;----------------------------------------
;stat: ok
proc line
push bp
mov bp,sp
push bx
push cx
push dx
push ax

; draws a line
    mov cx,bpWidth1
    lulaa:  
    call my_pixel
    add [x],1
    
    loop lulaa
    
pop dx
pop cx
pop bx
pop ax
pop bp

ret 2
endp line
;-----------------------------------------
;stat: to fix
;si=I 0-7 ,A[I]=[bx + si] 1-8
proc creatArray

    push ax
    push bx
    push cx
    push dx

    mov bx,offset boardArray; dx points to boardArray
    mov si, 0
    mov cx, 8

backToStart: 
    add [bx + si],1
    cmp [bx + si],8 ;first row
jg WaitingEnd ;endAndWait 
;***
nextRow:
    add si,1 ;i++
    cmp si,7
jg result

plusOneCol:
    add [bx + si],1
    cmp [bx + si],8
jg resetPlace


mov di,si
mov cx,si
rowsCheck:
    
    mov [cxSave],cx

    sub di,1
 
    mov ax,[bx + si] ;a[i]
    mov dx,[bx + di] ;a[k]
    mov dh,0
    
    cmp ax,dx
    je plusOneCol

    mov [rowSave],di
    sub [rowSave],si ; k - i
    mov cx,[rowSave]
    
    sub ax,dx ; a[i] - a[k]
    
    cmp ax,0
    jg CheckSecondArg 
    neg ax
    
    CheckSecondArg:
    cmp cx,0
    jg CompareArg 
    neg cx
    
    CompareArg:
    cmp cx,ax
    je plusOneCol
    
    cmp di,0
    je nextRow
    
    mov cx,[cxSave]

loop rowsCheck
jmp nextRow


resetPlace:
    mov [bx + si],0
    sub si,1
    cmp si,0
    je backToStart
    jmp plusOneCol

result:
    add [winNum],1
    
    mov dx, offset resultNumber
    mov ah,9
    int 21h
    
    cmp [winNum],57
    jg temp_num
    jmp none1
    
temp_num:
    mov [winNum],48
    add temp,1
    
none1:
    mov dx, offset temp
    mov ah,9
    int 21h
    
    mov dx, offset winNum
    mov ah,9
    int 21h
    
    
    mov si,0
printQLoop:
    
    call printQ  
    
    add si,1
    cmp si,8
    js printQLoop
    
    mov dx, offset nextResult
    mov ah,9
    int 21h
    
    Waiting:
    ; Wait for key press
    mov ah,00h
    int 16h
    
    ;q_for_quit
    cmp al,'q'
    je end1
    
    ;x_for_nextQ
    cmp al,'x'
    jne Waiting
    
    mov [x],50
    mov [y],20
    mov [color],1
    call chessBoard
    
    jmp plusOneCol

WaitingEnd:
; Wait for key press
    mov ah,00h
    int 16h
    
    end1:
    pop dx
    pop cx
    pop bx
    pop ax

ret
endp creatArray
;-----------------------------------------*************
proc printQ
;stat : to write
    push ax
    push bx
    push cx
    push dx

    mov ax, 0

    mov al, [bx + si]
    sub al, 1
    mov bl, 20
    mul bl
    mov dx,ax  ;?????????? ??????
    add dx,15;//mov the queen to the middale

    mov ax, 0
    mov bl, 20
    mov ax, si
    mul bl

    mov [y],ax
    add [y],30
    mov [x],dx
    add [x],60
    mov [width1],10;not alwas need
    mov [height1],10;not alwas need 
    loppOfPisels2:
    mov [color],0100b
    
    push [width1]
    call line

    sub [y],1
    sub [x],10
    sub [height1],1
    mov cx,[height1]
    loop loppOfPisels2

    pop dx
    pop cx
    pop bx
    pop ax

ret
endp printQ
;--------------------------------------------pic staff
;stat: good
proc OpenFile
; Open file
    mov ah, 3Dh
    xor al, al
    mov dx, offset filename
    int 21h
    jc openerror
    mov [filehandle], ax

    ret
    openerror:
    mov dx, offset ErrorMsg
    mov ah, 9h
    int 21h
    ret
endp OpenFile
;--------------------------------------------------pic staff
;stat: good
proc ReadPalette
    ; Read BMP file color palette, 256 colors * 4 bytes (400h)
    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette
    int 21h
    ret
endp ReadPalette
;------------------------------------------------------------------pic staff
;stat: good
proc CopyPal
    ; Copy the colors palette to the video memory
    ; The number of the first color should be sent to port 3C8h
    ; The palette is sent to port 3C9h
    mov si,offset Palette
    mov cx,256
    mov dx,3C8h
    mov al,0
    ; Copy starting color to port 3C8h
    out dx,al
    ; Copy palette itself to port 3C9h
    inc dx
    PalLoop:
    ; Note: Colors in a BMP file are saved as BGR values rather than RGB.
    mov al,[si+2] ; Get red value.
    ;shr al,2 ; Max. is 255, but video palette maximal
    ; value is 63. Therefore dividing by 4.
    out dx,al ; Send it.
    mov al,[si+1] ; Get green value.
    shr al,2
    out dx,al ; Send it.
    mov al,[si] ; Get blue value.
    shr al,2
    out dx,al ; Send it.
    add si,4 ; Point to next color.
    ; (There is a null chr. after every color.)

    loop PalLoop
    ret
endp CopyPal
;----------------------------------------------------------------pic staff
;stat: good
proc ReadHeader
    ; Read BMP file header, 54 bytes
    mov ah,3fh
    mov bx, [filehandle]
    mov cx,54
    mov dx,offset Header
    int 21h
    ret
endp ReadHeader
;----------------------------------------------------------------pic staff
;stat: good
proc CopyBitmap
    ; BMP graphics are saved upside-down.
    ; Read the graphic line by line (200 lines in VGA format),
    ; displaying the lines from bottom to top.
    mov ax, 0A000h
    mov es, ax
    mov cx,200
    PrintBMPLoop:
    push cx
    ; di = cx*320, point to the correct screen line
    mov di,cx
    shl cx,6
    shl di,8
    add di,cx
    ; Read one line
    mov ah,3fh
    mov cx,320
    mov dx,offset ScrLine
    int 21h
    ; Copy one line into video memory
    cld ; Clear direction flag, for movsb
    mov cx,320
    mov si,offset ScrLine
    rep movsb ; Copy line to the screen
    pop cx
    loop PrintBMPLoop
    ret
endp CopyBitmap
;--------------------------------------------pic staff and the loop for loading (movingCube)
;stat: good
proc playPic
    push ax
    push bx
    push cx
    push dx

    ; Graphic mode
    mov ax, 13h
    int 10h

    call OpenFile
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap
;***
    mov cx,22 ;number of times movingCube is called
    delay2:
    call movingCube
    loop delay2

    call resetScreen

    ; Return to text mode
    mov ah, 0
    mov al, 2
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax

ret
endp playPic
;--------------------------------------------small pic
;stat: good
proc OpenShowBmp near
    push cx
    push bx

    call OpenBmpFile
    cmp [ErrorFile],1
    je @@ExitProc
    
    call ReadBmpHeader
    ; from  here assume bx is global param with file handle. 
    call ReadBmpPalette
    call CopyBmpPalette
    call ShowBMP
    call CloseBmpFile

@@ExitProc:
    pop bx
    pop cx
    ret
endp OpenShowBmp
;-------------------------------------------------------small pic
;stat: good
; input dx filename to open
proc OpenBmpFile near                        
    mov ah, 3Dh
    xor al, al
    int 21h
    jc @@ErrorAtOpen
    mov [FileHandle1], ax
    jmp @@ExitProc
    
@@ErrorAtOpen:
    mov [ErrorFile],1
@@ExitProc: 
    ret
endp OpenBmpFile
;-----------------------------------------------------------small pic
;stat: good
proc CloseBmpFile near
    mov ah,3Eh
    mov bx, [FileHandle1]
    int 21h
    ret
endp CloseBmpFile
;-----------------------------------------------------------small pic
;stat: good
; Read 54 bytes the Header
proc ReadBmpHeader  near                    
    push cx
    push dx
    
    mov ah,3fh
    mov bx, [FileHandle1]
    mov cx,54
    mov dx,offset Header1
    int 21h
    
    pop dx
    pop cx
    ret
endp ReadBmpHeader
;-------------------------------------------------------------small pic
;stat: good
proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)     
    push cx
    push dx
    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette1
    int 21h
    pop dx
    pop cx
    
    ret
endp ReadBmpPalette
;---------------------------------------------------------------small pic
; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
;stat: good
proc CopyBmpPalette near                    
    push cx
    push dx
    
    mov si,offset Palette1
    mov cx,256
    mov dx,3C8h
    mov al,0  ; black first                         
    out dx,al ;3C8h
    inc dx    ;3C9h
CopyNextColor:
    mov al,[si+2]       ; Red               
    shr al,2            ; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).             
    out dx,al                       
    mov al,[si+1]       ; Green.                
    shr al,2            
    out dx,al                           
    mov al,[si]         ; Blue.             
    shr al,2            
    out dx,al                           
    add si,4            ; Point to next color.  (4 bytes for each color BGR + null)             
    loop CopyNextColor
    
    pop dx
    pop cx
    
    ret
endp CopyBmpPalette
;-------------------------------------------------------------------small pic
;stat: good
proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
    push cx
    
    mov ax, 0A000h
    mov es, ax
    mov cx,[BmpRowSize]
    mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
    xor dx,dx
    mov si,4
    div si
    mov bp,dx
    mov dx,[BmpLeft]
    
@@NextLine:
    push cx
    push dx
    
    mov di,cx  ; Current Row at the small bmp (each time -1)
    add di,[BmpTop] ; add the Y on entire screen
    
 
    ; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
    mov cx,di
    shl cx,6
    shl di,8
    add di,cx
    add di,dx
    ;?????? ?????????? ????? ?????? ???? ??????????! ???? ???????? ???????? ????????????????
    ; small Read one line
    mov ah,3fh
    mov cx,[BmpColSize]  
    add cx,bp  ; extra  bytes to each row must be divided by 4
    mov dx,offset ScreenLineMax
    int 21h
    ; Copy one line into video memory
    cld ; Clear direction flag, for movsb
    mov cx,[BmpColSize]  
    mov si,offset ScreenLineMax
    rep movsb ; Copy line to the screen
    
    pop dx
    pop cx
     
    loop @@NextLine
    
    pop cx
    ret
endp ShowBMP 
;---------------------------------------------------------------------movingCube
;stat: good
proc movingCube
    push ax
    push bx
    push cx
    push dx

    ;start delay
    mov bp, 15
    mov si, 15
    delay1:
    dec bp
    nop
    jnz delay1
    dec si
    cmp si,0    
    jnz delay1
    ;end 1 sec delay

    ;add moving  pic
    mov [BmpLeft],130 ; the place of left up point(x)
    mov dx,[counterMove]
    add [BmpLeft],dx
    mov [BmpTop],145  ;(y)
    mov [BmpColSize], 16 ;size width
    mov [BmpRowSize], 6 ;size height 

    mov dx,offset SmallPicName
    call OpenShowBmp 
    add [counterMove],2
    
    pop dx
    pop cx
    pop bx
    pop ax

ret
endp movingCube
;------------------------------------------
start:
    mov ax, @data
    mov ds, ax
;------------------------------------------ 
;stat: need to add staff

    call playPic
    
    call startGame

    call chessBoard
    
    ; Wait for key press
    mov ah,00h
    int 16h
    
    call resetScreen

    call creatArray
        
; Return to text mode
mov ah, 0
mov al, 2
int 10h

exit:
    mov ax, 4c00h
    int 21h
END start