#include<stdint.h>
#define START_ADDR 0xB

bool glob_cl = true, sqr = false;
uint8_t sqr_cl = 0;

void clear_screen(unsigned char color)
{
    int i = 64000; //320*200
    unsigned char* vm = (unsigned char*) 0xa0000 + i-1;

    while(i--)
    {
        if(*vm != color)
            *vm = color;
        vm--;
    }
}

void delay(unsigned int time)
{
    while(time)
        time--;
}

void draw_rect(int start_px, int start_py, int larg, int alt, int color)
{
    unsigned char* vm = (unsigned char*) 0xa0000 + start_px+(320*start_py);
    int lg = larg;

    while(alt--)
    {
        while(lg--)
            *vm++ = color;

        vm = (vm - larg)+320;
        lg = larg;
    }
}

void out(uint16_t port, uint8_t data)
{
    asm("out %0, %1"
        :
        :"a"(data), "Nd"(port));

    return;
}

void outw(uint16_t port, uint16_t data)
{
    asm("out %0, %1"
        :
        :"a"(data), "Nd"(port));

    return;
}

uint8_t in(uint16_t port)
{
    uint8_t data;
    asm("in %1, %0"
        :"=a"(data)
        :"Nd"(port));

    return data;
}

uint16_t inw(uint16_t port)
{
    uint16_t data;
    asm("in %1, %0"
        :"=a"(data)
        :"Nd"(port));

    return data;
}

extern "C" void  ATA_ack()
{
    glob_cl = false;

    return;
}

extern "C" void  exc_ack()
{
    clear_screen(4);
    return;
}

void ATA_write(uint32_t LBA,  uint8_t sec_n, uint16_t* data_buffer)
{
    uint8_t bt = LBA >> 24 | 0xE0;

    out(0x1F6, bt);

    uint8_t delay = in(0x1F7);
    delay = in(0x1F7);
    delay = in(0x1F7);
    delay = in(0x1F7);

    out(0x1F2, sec_n); //number of sectors to write

    out(0x1F3, LBA);

    out(0x1F4, LBA >> 8);

    out(0x1F5, LBA >> 16);

    out(0x1F7, 0x30); //read with retry = 0x20, write with retry = 0x30

    //clear_screen(3);

    //servicing

    while( (in(0x1F7) & 0x8) == 0 ) {}

    for(int i=0; i<sec_n*256; i++)
        outw(0x1F0, data_buffer[i]);

    out(0x1F7, 0xE7); //cache flush

    return;
}

void clean_sec(uint32_t start_addr)
{
    uint16_t data[256];

    for(int di=0; di<256; di++)
        data[di] = 0x0;

    for(int i=0; i<127; i++)
        ATA_write(start_addr+i, 0x1, data);

    return;
}
void screenshot(uint32_t start_addr, uint16_t* header_addr)
{
    uint16_t data[256];

    uint8_t cnt = 0;

    uint16_t* vm = (uint16_t*) 0xa0000 + (32000 - 160);

    //write first header sector
    for(int i=0; i<256; i++)
        data[i] = *header_addr++;

    ATA_write(start_addr, 0x1, data);


    //write second header sector
    for(int i=0; i<256; i++)
        data[i] = *header_addr++;


    ATA_write(start_addr+1, 0x1, data);

    //merge last header part and first video memory part

    for(int i = 0; i<256; i++)
    {

        if(i<=26)
            data[i] = *header_addr++; //*vm++;
        else
        {
            if(cnt == 160) //160
            {
                vm = vm - 320;
                cnt = 0;
            }

            cnt++;

            data[i] = *vm++; //*header_addr++;
        }

    }

    //write video memory

    ATA_write(start_addr+2, 0x1, data);

    for(int i=0; i<125; i++)
    {
        for(int di=0; di<256; di++)
        {
            if(cnt == 160)
            {
                vm = vm - 320;
                cnt = 0;
            }

            cnt++;

            data[di] = *vm++;
        }

        ATA_write(start_addr+3+i, 0x1, data);
    }

    return;
}

extern "C" void keyb_irq()
{
    switch( in(0x60) )
    {
    case 0x82: //1 released
        sqr_cl = 1;
        break;
    case 0x83: //2 released
        sqr_cl = 2;
        break;
    case 0x84: //3 released
        sqr_cl = 3;
        break;
    case 0x85: //4 released
        sqr_cl = 4;
        break;
    case 0x86: //5 released
        sqr_cl = 5;
        break;
    case 0x87: //6 released
        sqr_cl = 6;
        break;
    case 0x88: //7 released
        sqr_cl = 7;
        break;
    case 0x89: //8 released
        sqr_cl = 8;
        break;
    case 0x8A: //9 released
        sqr_cl = 9;
        break;
    case 0x9F: //screenshot
        screenshot(START_ADDR, (uint16_t*)0xBC50);
        break;
    case 0xA2:
        if(!sqr)
            sqr = true;
        else
            sqr = false;
        break;
    }

    return;
}

void draw_bmp(unsigned char* addr, uint16_t posx, unsigned char posy)
{
    uint16_t width = *( (uint16_t*) (addr+18) );
    unsigned char height = *(addr+22);
    unsigned char *addr_b = addr;
    //addr += 1078; //jump to pixel data

    unsigned char* vm = (unsigned char*) 0xa0000 + posx+(320*posy);
    int _x;

    while(height)
    {
        _x = width;

        addr = (addr_b + 1078) + ( (width*height--)-width);


        while(_x--)
        {
            if(*addr != *vm)
                *vm = *addr;
            vm++;
            addr++;
        }
        //*vm++ = *addr++;

        vm = (vm - width)+320;

    }
}

void draw_bmp_subtract(unsigned char* addr, uint16_t posx, unsigned char posy, unsigned char color_to_subtract)
{
    uint16_t width = *( (uint16_t*) (addr+18) );
    unsigned char height = *(addr+22);
    unsigned char *addr_b = addr;
    //addr += 1078; //jump to pixel data

    unsigned char* vm = (unsigned char*) 0xa0000 + posx+(320*posy);
    int _x;
    while(height)
    {
        _x = width;

        addr = (addr_b + 1078) + ( (width*height--)-width);

        while(_x--)
        {
            if(*addr != color_to_subtract && *addr != *vm)
                *vm = *addr;
            vm++;
            addr++;
        }


        vm = (vm - width)+320;

    }
}

void draw_bmp_region(unsigned char* addr, uint16_t posx, unsigned char posy,
                     uint16_t regX, unsigned char regY, uint16_t regW, unsigned char regH)
{
    uint16_t width = *( (uint16_t*) (addr+18) );
    unsigned char height = *(addr+22);

    unsigned char* vm = (unsigned char*) 0xa0000 + posx+(320*posy);
    int _x;

    addr += 1078;

    addr += (width*height) - (regX+(width*regY));

    addr-= width-(regX*2);

    while(regH)
    {
        _x = regW;

        while(_x--)
        {
            if(*addr != *vm)
                *vm = *addr;
            vm++;
            addr++;
        }

        addr -= (regW+regX)+(width-regX);

        regH--;

        vm = (vm - regW)+320;
    }
}

void draw_bmp_region_subtract(unsigned char* addr, uint16_t posx, unsigned char posy,
                     uint16_t regX, unsigned char regY, uint16_t regW, unsigned char regH, unsigned char color_to_subtract)
{
    uint16_t width = *( (uint16_t*) (addr+18) );
    unsigned char height = *(addr+22);

    unsigned char* vm = (unsigned char*) 0xa0000 + posx+(320*posy);
    int _x;

    addr += 1078;

    addr += (width*height) - (regX+(width*regY));

    addr-= width-(regX*2);

    while(regH)
    {
        _x = regW;

        while(_x--)
        {
            if(*addr != color_to_subtract && *addr != *vm)
                *vm = *addr;
            vm++;
            addr++;
        }

        addr -= (regW+regX)+(width-regX);

        regH--;

        vm = (vm - regW)+320;
    }
}

struct sprite_data
{
    unsigned char* sprite_address;

    uint16_t       position_x;
    unsigned char  position_y;

    uint16_t       region_position_x;
    unsigned char  region_position_y;

    uint16_t       region_width;
    unsigned char  region_heigth;

    unsigned char sub_col;
};

class sprite_animation
{
    sprite_data* sprite_s;
    unsigned int dl;
    unsigned int sprite_n;
    unsigned char subtract_col;
public:
    sprite_animation(sprite_data* _sprite_s, unsigned int _sprite_n, unsigned int _dl, unsigned char _subtract_col)
    {
        sprite_s = _sprite_s;
        dl = _dl;
        sprite_n = _sprite_n;
        subtract_col = _subtract_col;
    }

    void play()
    {
        for(unsigned int i = 0; i<sprite_n; i++)
        {

            draw_bmp_region_subtract(sprite_s[i].sprite_address,
                                     sprite_s[i].position_x,
                                     sprite_s[i].position_y,
                                     sprite_s[i].region_position_x,
                                     sprite_s[i].region_position_y,
                                     sprite_s[i].region_width,
                                     sprite_s[i].region_heigth,
                                     subtract_col);
            delay(dl);
        }
    }
};

extern "C" void KERNEL_START()
{
    sprite_data sprite_sheet[8];

    sprite_sheet[0].sprite_address    = (unsigned char*) 0x7E00;
    sprite_sheet[0].position_x        = 0;
    sprite_sheet[0].position_y        = 0;
    sprite_sheet[0].region_position_x = 0;
    sprite_sheet[0].region_position_y = 0;
    sprite_sheet[0].region_width      = 32;
    sprite_sheet[0].region_heigth     = 58;

    sprite_sheet[1].sprite_address    = (unsigned char*) 0x7E00;
    sprite_sheet[1].position_x        = 0;
    sprite_sheet[1].position_y        = 0;
    sprite_sheet[1].region_position_x = 32;
    sprite_sheet[1].region_position_y = 0;
    sprite_sheet[1].region_width      = 32;
    sprite_sheet[1].region_heigth     = 58;

    sprite_sheet[2].sprite_address    = (unsigned char*) 0x7E00;
    sprite_sheet[2].position_x        = 0;
    sprite_sheet[2].position_y        = 0;
    sprite_sheet[2].region_position_x = 64;
    sprite_sheet[2].region_position_y = 0;
    sprite_sheet[2].region_width      = 32;
    sprite_sheet[2].region_heigth     = 58;

    sprite_sheet[3].sprite_address    = (unsigned char*) 0x7E00;
    sprite_sheet[3].position_x        = 0;
    sprite_sheet[3].position_y        = 0;
    sprite_sheet[3].region_position_x = 96;
    sprite_sheet[3].region_position_y = 0;
    sprite_sheet[3].region_width      = 32;
    sprite_sheet[3].region_heigth     = 58;

    sprite_sheet[4].sprite_address    = (unsigned char*) 0x7E00;
    sprite_sheet[4].position_x        = 0;
    sprite_sheet[4].position_y        = 0;
    sprite_sheet[4].region_position_x = 128;
    sprite_sheet[4].region_position_y = 0;
    sprite_sheet[4].region_width      = 32;
    sprite_sheet[4].region_heigth     = 58;

    sprite_sheet[5].sprite_address    = (unsigned char*) 0x7E00;
    sprite_sheet[5].position_x        = 0;
    sprite_sheet[5].position_y        = 0;
    sprite_sheet[5].region_position_x = 160;
    sprite_sheet[5].region_position_y = 0;
    sprite_sheet[5].region_width      = 32;
    sprite_sheet[5].region_heigth     = 58;

    sprite_sheet[6].sprite_address    = (unsigned char*) 0x7E00;
    sprite_sheet[6].position_x        = 0;
    sprite_sheet[6].position_y        = 0;
    sprite_sheet[6].region_position_x = 192;
    sprite_sheet[6].region_position_y = 0;
    sprite_sheet[6].region_width      = 32;
    sprite_sheet[6].region_heigth     = 58;

    sprite_sheet[7].sprite_address    = (unsigned char*) 0x7E00;
    sprite_sheet[7].position_x        = 0;
    sprite_sheet[7].position_y        = 0;
    sprite_sheet[7].region_position_x = 224;
    sprite_sheet[7].region_position_y = 0;
    sprite_sheet[7].region_width      = 32;
    sprite_sheet[7].region_heigth     = 58;


    sprite_animation spr_cl(sprite_sheet, 8, 10000000, 2);


    while(true)
    {
        if(glob_cl)
        {
        for(unsigned int i = 0; i<8; i++)
        {

            draw_bmp((unsigned char*) 0xBC50, 0, 0);

            if(sqr)
                draw_rect(180, 70, 100, 100, sqr_cl);

            draw_bmp_region_subtract(sprite_sheet[i].sprite_address,
                                     i*10, //sprite_sheet[i].position_x,
                                     0, //sprite_sheet[i].position_y,
                                     sprite_sheet[i].region_position_x,
                                     sprite_sheet[i].region_position_y,
                                     sprite_sheet[i].region_width,
                                     sprite_sheet[i].region_heigth,
                                     2);

            draw_bmp_region_subtract(sprite_sheet[i].sprite_address,
                                     0, //sprite_sheet[i].position_x,
                                     58, //sprite_sheet[i].position_y,
                                     sprite_sheet[i].region_position_x,
                                     sprite_sheet[i].region_position_y,
                                     sprite_sheet[i].region_width,
                                     sprite_sheet[i].region_heigth,
                                     2);

            draw_bmp_region(sprite_sheet[i].sprite_address,
                            0, //sprite_sheet[i].position_x,
                            116, //sprite_sheet[i].position_y,

                            0,
                            0,

                            32,
                            58);


            delay(150000000);
        }
        }
    }

    asm("cli \n\t");
    asm("hlt \n\t");
}
