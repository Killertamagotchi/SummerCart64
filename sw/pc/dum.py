import os
import serial
import sys



class SC64:
    __SDRAM_SIZE = 64 * 1024 * 1024

    __CONFIG_QUERY_SAVE_TYPE = 4
    __CONFIG_QUERY_SAVE_OFFSET = 7

    def __init__(self, port):
        self.__serial = serial.Serial(port)
        self.__save_type = self.__query_config(self.__CONFIG_QUERY_SAVE_TYPE)
        self.__save_offset = self.__query_config(self.__CONFIG_QUERY_SAVE_OFFSET)
        print('{:08X}'.format(self.__save_type))
        print('{:08X}'.format(self.__save_offset))


    def __query_config(self, query):
        self.__serial.write(b'CMDQ')
        self.__serial.write(query.to_bytes(4, byteorder='big'))
        self.__serial.write(bytes(4))
        value = self.__serial.read(4)
        if (self.__serial.read(4).decode() != 'CMPQ'):
            raise Exception('Bad query response')
        return int.from_bytes(value, byteorder='big')


    def __save_length(self):
        return {
            0: 0,
            1: 512,
            2: 2048,
            3: (32 * 1024),
            4: (128 * 1024),
            5: (3 * 32 * 1024),
            6: (128 * 1024),
            7: 0
        }[self.__save_type]


    def dump_save(self, file):
        length = self.__save_length()
        if (length == 0):
            raise Exception('No save type is selected')
        self.__serial.write(b'CMDR')
        self.__serial.write(self.__save_offset.to_bytes(4, byteorder='big'))
        self.__serial.write(length.to_bytes(4, byteorder='big'))
        save = self.__serial.read(length)
        response = self.__serial.read(4)
        if (response.decode() == 'CMPR'):
            with open(file, 'wb') as f:
                f.write(save)
        else:
            raise Exception('There was a problem while dumping save data')


    def redump_save(self, file):
        length = self.__save_length()
        if (not length):
            raise Exception('No save type is selected')
        if (os.path.getsize(file) != length):
            raise Exception('Wrong save file size')
        with open(file, 'rb') as f:
            self.__serial.write(b'CMDW')
            self.__serial.write(self.__save_offset.to_bytes(4, byteorder='big'))
            self.__serial.write(length.to_bytes(4, byteorder='big'))
            self.__serial.write(f.read())
            response = self.__serial.read(4)
            if (response.decode() != 'CMPW'):
                raise Exception('There was a problem while redumping save data')


    def dump_all(self, file):
        self.__serial.write(b'CMDR')
        self.__serial.write((0).to_bytes(4, byteorder='big'))
        self.__serial.write((self.__SDRAM_SIZE).to_bytes(4, byteorder='big'))
        save = self.__serial.read(self.__SDRAM_SIZE)
        response = self.__serial.read(4)
        if (response.decode() == 'CMPR'):
            with open(file, 'wb') as f:
                f.write(save)
        else:
            raise Exception('There was a problem while dumping all data')



mode = 'r'
file = 'save.dat'
port = 'COM7'

if (len(sys.argv) >= 2):
    mode = sys.argv[1]
if (len(sys.argv) >= 3):
    file = sys.argv[2]
if (len(sys.argv) >= 4):
    port = sys.argv[3]

sc64 = SC64(port)

if (mode == 'r'):
    sc64.dump_save(file)
elif (mode == 'w'):
    sc64.redump_save(file)
elif (mode == 'a'):
    sc64.dump_all(file)
