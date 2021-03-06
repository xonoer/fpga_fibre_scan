--*****************************************************************************
--  @Copyright 2008 by guyoubao, All rights reserved.                    
--  Module name : vhdl_code_demo
--  Call by      : 
--  Description   : this module is the top module of demo.
--  IC          : EP1C4F400C8
--  Version      : A                                                   
--  Note:        : this is a demo
--  Author       : guyoubao 
--  Date         : 2003.09.07                                                  
--  Update      : 
--  2003.10.15  : xxx(who?)
--                  add xxxx
--                  modify xxxxx  
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity LED_HANDLE is
port
(
    I_26M_clk                        :   in    std_logic;
    I_reset_n                        :   in    std_logic;
    I_led_dis                        :   in   std_logic_vector(3 downto 0);
    
    I_adc_dis                        :   in    std_logic;
    I_fifo_full                      :   in    std_logic;
                                   
    O_fpga_led0                      :   out   std_logic; 
    O_fpga_led1                      :   out   std_logic;                                     
    O_fpga_led2                      :   out   std_logic;   --CPUд��ָʾ
    O_fpga_led3                      :   out   std_logic    --FPGA����ָʾ
);
end LED_HANDLE;

architecture ARC_LED_HANDLE of LED_HANDLE is

signal S_case_cnt     : std_logic_vector(23 downto 0);--
signal S_case         : std_logic_vector(2 downto 0);

signal S_init         : std_logic;
signal S_time_tick    : std_logic;
signal S_time_tick_buf    : std_logic;

signal S_fpga_led0    : std_logic; 
signal S_fpga_led1    : std_logic;                                     
signal S_fpga_led2    : std_logic;   --CPUд��ָʾ
signal S_fpga_led3    : std_logic;    --FPGA����ָʾ
    
begin

O_fpga_led0      <=       S_fpga_led0;
O_fpga_led1      <=       S_fpga_led1;
O_fpga_led2      <=       S_fpga_led2;
O_fpga_led3      <=       S_fpga_led3;

-------------------------------
--The state transfer one time in 1 second
-------------------------------
process(I_26M_clk, I_reset_n)
begin
    if I_reset_n = '0' then
        S_case <= (others=>'0');
        S_case_cnt <= (others=>'0');
        S_init <= '0';
        S_time_tick <= '0';
    elsif rising_edge(I_26M_clk) then
        --if S_case_cnt >= x"10111110" then   --200MHz
        --if S_case_cnt >=   x"019B4E81" then     --20MHz
        
        S_case_cnt <= S_case_cnt + 1;       
        if (S_case_cnt = 0)then     --20MHz      
                    
            S_time_tick <= not S_time_tick;   --ʱ�ӽ��ģ�1Sһ��
                        
            if S_case >= "100" then
                S_init <= '1';
                S_case <= (others=>'0');
            else  
                S_case <= S_case + 1;     -- Increment state on one second
            end if;
        end if;
    else  
        null;
    end if;
end process;

process(I_26M_clk, I_reset_n)
begin
    if I_reset_n = '0' then
        S_fpga_led2 <= '1';
        S_fpga_led3 <= '1'; 
    elsif rising_edge(I_26M_clk) then
        if (I_adc_dis = '1') then
            if (S_time_tick = '1') then
                S_fpga_led2   <= '0';  
            else
                S_fpga_led2   <= '1'; 
            end if;        
        else
            S_fpga_led2 <= '1';
        end if;
        
        if (I_fifo_full = '1') then    --FIFO is full
            if (S_time_tick = '1') then
                S_fpga_led3   <= '0';  
            else
                S_fpga_led3   <= '1'; 
            end if;        
        else
            S_fpga_led3 <= '1';
        end if;
        
    else  
        null;
    end if;
end process;
-------------------------------
--Output the led signal one second
-------------------------------
process(I_reset_n,I_26M_clk)
begin
  if I_reset_n = '0' then
    S_fpga_led0   <= '1';
    S_fpga_led1   <= '1';
 --   S_fpga_led2   <= '1';
 --   S_fpga_led3   <= '1';
  else 
    if rising_edge(I_26M_clk) then
     --   if (S_init = '0') then
            case S_case is
              when "001" =>        
                S_fpga_led0   <= '0';
                S_fpga_led1   <= '1';
             --   S_fpga_led2   <= '1';
             --   S_fpga_led3   <= '1';         
              when "010" =>
                S_fpga_led0   <= '1';
                S_fpga_led1   <= '0';
             --   S_fpga_led2   <= '1';
             --   S_fpga_led3   <= '1';
              when "011" =>
                S_fpga_led0   <= '1';
                S_fpga_led1   <= '1';
             --   S_fpga_led2   <= '0';
             --   S_fpga_led3   <= '1';
              when "100" =>
                S_fpga_led0   <= '0';
                S_fpga_led1   <= '0';
             --   S_fpga_led2   <= '1';
             --   S_fpga_led3   <= '0';
           --   when "101" =>
           --     S_fpga_led0   <= '1';
           --     S_fpga_led1   <= '1';
           --     S_fpga_led2   <= '1';
           --     S_fpga_led3   <= '1';
           --   when "110" =>
           --     S_fpga_led0   <= '0';
           --     S_fpga_led1   <= '0';
           --     S_fpga_led2   <= '0';
           --     S_fpga_led3   <= '0';     
              when others =>            
                S_fpga_led0   <= '1';
                S_fpga_led1   <= '1';
           --     S_fpga_led2   <= '1';
           --     S_fpga_led3   <= '1';
            end case;
    --    else
    --        S_time_tick_buf <= S_time_tick;
    --        if(S_time_tick_buf = not S_time_tick)then
    --            S_fpga_led3 <= not S_fpga_led3;     --FPGA��������ָʾ��
    --        end if; 

    else
      null;
    end if;
  end if;
end process;

    
end ARC_LED_HANDLE;