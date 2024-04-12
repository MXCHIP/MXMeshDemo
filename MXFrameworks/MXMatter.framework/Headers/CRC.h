//
//  CRC.h
//  MXMatter
//
//  Created by khazan on 2023/4/12.
//

#include <stdio.h>

typedef uint32_t uint_len;

uint8_t crc4_itu(uint8_t *data, uint_len length);
uint8_t crc5_epc(uint8_t *data, uint_len length);
uint8_t crc5_itu(uint8_t *data, uint_len length);
uint8_t crc5_usb(uint8_t *data, uint_len length);
uint8_t crc6_itu(uint8_t *data, uint_len length);
uint8_t crc7_mmc(uint8_t *data, uint_len length);
uint8_t crc8(uint8_t *data, uint_len length);
uint8_t crc8_itu(uint8_t *data, uint_len length);
uint8_t crc8_rohc(uint8_t *data, uint_len length);
uint8_t crc8_maxim(uint8_t *data, uint_len length);
uint16_t crc16_ibm(uint8_t *data, uint_len length);
uint16_t crc16_maxim(uint8_t *data, uint_len length);
uint16_t crc16_usb(uint8_t *data, uint_len length);
uint16_t crc16_modbus(uint8_t *data, uint_len length);
uint16_t crc16_ccitt(uint8_t *data, uint_len length);
uint16_t crc16_ccitt_false(uint8_t *data, uint_len length);
uint16_t crc16_x25(uint8_t *data, uint_len length);
uint16_t crc16_xmodem(uint8_t *data, uint_len length);
uint16_t crc16_dnp(uint8_t *data, uint_len length);
uint32_t crc32(uint8_t *data, uint_len length);
uint32_t crc32_mpeg_2(uint8_t *data, uint_len length);

uint8_t SC_CRC8(uint8_t *pdata, uint16_t size);
