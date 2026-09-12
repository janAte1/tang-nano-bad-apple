import time
from machine import Pin, PWM

# Setup Buzzer Pin on GPIO 15
buzzer = PWM(Pin(15))

# Note Frequencies (Hz)
REST = 0
B0 = 31
C1 = 33
CS1 = 35
D1 = 37
DS1 = 39
E1 = 41
F1 = 44
FS1 = 46
G1 = 49
GS1 = 52
A1 = 55
AS1 = 58
B1 = 62
C2 = 65
CS2 = 69
D2 = 73
DS2 = 78
E2 = 82
F2 = 87
FS2 = 93
G2 = 98
GS2 = 104
A2 = 110
AS2 = 117
B2 = 123
C3 = 131
CS3 = 139
D3 = 147
DS3 = 156
E3 = 165
F3 = 175
FS3 = 185
G3 = 196
GS3 = 208
A3 = 220
AS3 = 233
B3 = 247
C4 = 262
CS4 = 277
D4 = 294
DS4 = 311
E4 = 330
F4 = 349
FS4 = 370
G4 = 392
GS4 = 415
A4 = 440
AS4 = 466
B4 = 494
C5 = 523
CS5 = 554
D5 = 587
DS5 = 622
E5 = 659
F5 = 698
FS5 = 740
G5 = 784
GS5 = 831
A5 = 880
AS5 = 932
B5 = 988
C6 = 1047
CS6 = 1109
D6 = 1175
DS6 = 1245
E6 = 1319
F6 = 1397
FS6 = 1480
G6 = 1568
GS6 = 1661
A6 = 1760
AS6 = 1865
B6 = 1976
C7 = 2093
CS7 = 2217
D7 = 2349
DS7 = 2489
E7 = 2637
F7 = 2794
FS7 = 2960
G7 = 3136
GS7 = 3322
A7 = 3520
AS7 = 3729
B7 = 3951
C8 = 4186
CS8 = 4435
D8 = 4699
DS8 = 4978

# Tempo and Whole Note duration setup
tempo = 138
wholenote = (60000 * 4) // tempo

main_melody = [
    # beginning melody
    C4, D4, DS4, F4, G4, REST, C5, AS4, G4, C4, G4, F4, DS4, D4, C4, D4, DS4, F4, G4,
    F4, DS4, D4, C4, D4, DS4, D4, C4, B3, D4, C4, D4, DS4, F4, G4, REST, C5, AS4, G4, C4, G4,
    F4, DS4, D4, C4, D4, DS4, F4, G4, F4, DS4, D4, REST, DS4, F4, REST, G4, C5, D5, DS5, F5,
    G5, C6, AS5, G5, C5, G5, F5, DS5, D5, C5, D5, DS5, F5, G5, F5, DS5, D5, C5, D5, DS5, D5,
    C5, B4, D5, C5, D5, DS5, F5, G5, C6, AS5, G5, C5, G5, F5, DS5, D5, C5, D5, DS5, F5, G5,
    F5, DS5, D5, REST, DS5, F5, G5,

    # chorus
    AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, F5, G5, F5, DS5, D5, AS4, C5, AS4, C5, D5, DS5, F5, G5, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, F5, G5, F5, DS5, D5, AS4, C5, AS4, C5, D5, DS5, F5, G5, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, F5, G5, F5, DS5, D5, AS4, C5, AS4, C5, D5, DS5, F5, G5, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, C6, D6, DS6, D6, C6, AS5, G5, F5, G5, F5, DS5, D5, AS4, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, F5, G5, F5, DS5, D5, AS4, C5, AS4, C5, D5, DS5, F5, G5, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, F5, G5, F5, DS5, D5, AS4, C5, AS4, C5, D5, DS5, F5, G5, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, F5, G5, F5, DS5, D5, AS4, C5, AS4, C5, D5, DS5, F5, G5, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, C6, D6, DS6, D6, C6, AS5, G5, F5, G5, F5, DS5, D5, AS4, C5,
    REST,

    # after chorus
    C6, AS5, C6, C6, AS5, C6, C6, AS5, C6, C6, AS5, C6, AS5, C6, AS5, C6, AS5, C6, DS6, C6,
    AS5, C6, C6, C6, REST, C4, DS4, F4, G4, FS4, G4, FS4, FS4, F4, F4, DS4,
    AS3, REST, DS4, REST, C4, C5,
    C6, C5, AS5, C5, G5, C5, FS5, C5, F5, C5, DS5,
    AS4, C5, DS5, DS5, C5, AS4, DS5, DS5, C5, AS4, DS5, F5, REST, DS5, AS4,
    C5, G4, AS4, C5, DS5, G4, AS4, C5, DS5, F5, AS4, C5, DS5, F5, G5, C5, DS5, F5, G5,
    AS5, C5, DS5, F5, AS5, C6, F5, G5, AS5, C6, DS6, G5, AS5, C6, DS6, G6, C7, DS7, G7,
    REST,

    # repeat beginning
    C4, D4, DS4, F4, G4, REST, C5, AS4, G4, C4, G4, F4, DS4, D4, C4, D4, DS4, F4, G4,
    F4, DS4, D4, C4, D4, DS4, D4, C4, B3, D4, C4, D4, DS4, F4, G4, REST, C5, AS4, G4, C4, G4,
    F4, DS4, D4, C4, D4, DS4, F4, G4, F4, DS4, D4, REST, DS4, F4, REST, G4, C5, D5, DS5, F5,
    G5, C6, AS5, G5, C5, G5, F5, DS5, D5, C5, D5, DS5, F5, G5, F5, DS5, D5, C5, D5, DS5, D5,
    C5, B4, D5, C5, D5, DS5, F5, G5, C6, AS5, G5, C5, G5, F5, DS5, D5, C5, D5, DS5, F5, G5,
    F5, DS5, D5, REST, DS5, F5, G5,

    # chorus
    AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, F5, G5, F5, DS5, D5, AS4, C5, AS4, C5, D5, DS5, F5, G5, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, F5, G5, F5, DS5, D5, AS4, C5, AS4, C5, D5, DS5, F5, G5, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, F5, G5, F5, DS5, D5, AS4, C5, AS4, C5, D5, DS5, F5, G5, C5,
    G5, AS5, AS5, C6, G5, F5, G5, F5, G5, AS5, C6, G5, F5, G5, C6, D6, DS6, D6, C6, AS5, G5, F5, G5, F5, DS5, D5, AS4, C5,

    # last chorus
    GS5, B5, B5, CS6, GS5, FS5, GS5, FS5, GS5, B5, CS6, GS5, FS5, GS5, FS5, GS5, FS5, E5, DS5, B4, CS5, B4, CS5, DS5, E5, FS5, GS5, CS5,
    GS5, B5, B5, CS6, GS5, FS5, GS5, FS5, GS5, B5, CS6, GS5, FS5, GS5, FS5, GS5, FS5, E5, DS5, B4, CS5, B4, CS5, DS5, E5, FS5, GS5, CS5,
    GS5, B5, B5, CS6, GS5, FS5, GS5, FS5, GS5, B5, CS6, GS5, FS5, GS5, FS5, GS5, FS5, E5, DS5, B4, CS5, B4, CS5, DS5, E5, FS5, GS5, CS5,
    GS5, B5, B5, CS6, GS5, FS5, GS5, FS5, GS5, B5, CS6, GS5, FS5, GS5, CS6, DS6, E6, DS6, CS6, B5, GS5, FS5, GS5, FS5, E5, DS5, B4, CS5,

    # last melody
    B5, CS6, GS5, FS5, GS5, FS5, GS5, FS5, REST, B5, DS6, FS6, CS6, DS6, E6, DS6, CS6, B5, GS5, FS5, GS5, FS5, B5,
    E7, DS7, CS7, B6, GS6, B6, FS6, B5, CS6, GS5, FS5, GS5, FS5, GS5, B5, CS6, GS5, FS5, GS5, CS6, DS6, E6, DS6, CS6, B5, GS5,
    FS5, GS5, FS5, GS5, FS5, GS5, E6, DS6, REST, B5, E6, B6, REST, B6, E7, FS7, REST
]

main_notes = [
    # beginning
    8, 8, 8, 8, -8, 16, 8, 8, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, -8, 16, 8, 8, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 4, 8, 8, 4, 8, 8, 8, 8, 4, 8, 8, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 4, 8, 8, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 4, 4, 4,

    # chorus
    8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, -4,
    4,

    8, 16, 8, 8, 16, 16, 8, 16, 16, 8, 16, 16, 16, 16, 16, 16, 16, 8, 8, 16,
    8, 8, 16, 8, 16, 16, 16, 16, 4, 8, 8, 16, 8, 16, 8, 8,
    -16, -16, -16, -16, -8, 16,
    16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 8,
    16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 8, 16, 16, 8, 8,
    8, 16, 16, -16, 16, 32, 32, 32, 16, 16, 32, 32, 32, 16, 16, 32, 32, 32, 16, 16, 32, 32,
    32, 16, 16, 32, 32, 32, 16, 32, 32, 32, 32, 16, 32, 32, 32, -16, -8,

    # repeat beginning
    8, 8, 8, 8, -8, 16, 8, 8, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, -8, 16, 8, 8, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 4, 8, 8, 4, 8, 8, 8, 8, 4, 8, 8, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 4, 8, 8, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 4, 4, 4,

    # chorus
    8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,

    # last chorus
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8,
    8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 2,

    # last melody
    8, 8, 8, 8, 4, 8, 8, -4, 16, 32, 32, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 4, 4,
    16, 16, 16, 16, 16, 16, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8, 4,
    8, 8, 8, 8, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, -4, 2
]

# Play function
def play_melody():
    for freq, note_type in zip(main_melody, main_notes):
        # Calculate note duration
        if note_type > 0:
            note_duration = wholenote // note_type
        else:
            note_duration = int((wholenote // abs(note_type)) * 1.5)

        # Play tone if freq is not REST
        if freq > 0:
            buzzer.freq(freq)
            buzzer.duty_u16(32768)  # 50% duty cycle
            time.sleep_ms(int(note_duration * 0.9))
            
            # Silence briefly between notes
            buzzer.duty_u16(0)
            time.sleep_ms(int(note_duration * 0.1))
        else:
            # REST note
            buzzer.duty_u16(0)
            time.sleep_ms(note_duration)

    # Ensure buzzer is off at the end
    buzzer.duty_u16(0)

# Run the melody
play_melody()