; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst                    ; Start of application

AppEntry                LD B, Escalar-MATRIZ_A          ; Guardamos en B el tamaño de la matriz
                        LD IX, MATRIZ_A                 ; Guardamos en IX la dirección de memoria de MATRIZ_A
                        LD IY, MATRIZ_RESULTADO         ; Guardamos en IY la dirección de memoria de MATRIZ_RESULTADO
BucleRecorreArray       LD L, B                         ; Guardamos en L el contenido de B ya que al ser un bucle doble, tenemos que guardar por donde va el primero
                        LD DE, (Escalar)                ; Cargamos en E el contenido de Escalar, que será la condición del segundo bucle
                        LD B, E                         ; Cargamos en B el contenido de E
BucleSumar              CALL SumaElementos              ; Llamamos a la rutirna SumaElementos
                        LD DE, (MATRIZ_Z)               ; Cargamos en E el contenido de MATRIZ_Z
                        LD (IY), E                      ; Cargamos en HL el contenido de E
                        DJNZ BucleSumar                 ; Cerramos el segundo bucle
                        INC IX                          ; Incrementamos IX
                        INC IY                          ; Incrementamos IY
                        LD B, L                         ; Cargamos en el cumulador el contenido de L, que es por donde va el primer bucle
                        DJNZ BucleRecorreArray          ; Cerramos el primer bucle
Final                   halt                            ; Final del codigo
                        jp Final                        ; Final del codigo

SumaElementos           LD A, (IY)                      ; Cargamos en el acumulador el contenido de IY
                        ADD (IX)                        ; Sumamos el contenido de IX
                        LD (MATRIZ_Z), A                ; Cargamos en MATRIZ_Z el contenido del acumulador
                        RET                             ; Vovemos el bucle main

; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 equ *-1                         ; The last used byte's address

MATRIZ_A                defb 1,2,3,4,5,6,7,8,9
Escalar                 defb 3                          ; Escalar por el que se multiplica la matriz
MATRIZ_RESULTADO        defs Escalar-MATRIZ_A           ; Matriz que guarda el resultado
MATRIZ_Z                defs 1                          ; Definimos la variable que guarda el resultado de la suma
; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1     ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 equ AppEntry                            ; Tell the emulator where to start
Zeus_SP                 equ $FF40                               ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry    ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
;                        import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader


