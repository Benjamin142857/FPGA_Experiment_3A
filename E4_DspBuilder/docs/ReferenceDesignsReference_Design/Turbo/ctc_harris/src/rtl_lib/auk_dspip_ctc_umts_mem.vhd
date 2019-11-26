-------------------------------------------------------------------------------
-- Title         : row or coloumn interleaver table
-- Project       : umts_interleaver
-------------------------------------------------------------------------------
-- File          : $Workfile:   aukui_itlv_table_e.vhd  $
-- Revision      : $Revision: #1 $
-- Author        : Volker Mauer
-- Checked in by : $Author: zpan $
-- Last modified : $Date: 2009/06/19 $
-------------------------------------------------------------------------------
-- Description :
--
-- RAM
--
-- Copyright 2000 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------------
-- Modification history :
-- $Log: auk_dspip_ctc_umts_mem.vhd,v $
-- Revision 1.4  2008/02/14 00:00:04  zpan
-- change inferred ram for QII 7.2
--
-- Revision 1.3  2008/02/13 22:32:51  zpan
-- use common ctc_umts_libs
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library ieee;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.all;
entity auk_dspip_ctc_umts_mem is

  generic (
    gADDR_WIDTH : integer := 8;
    gDATA_WIDTH : integer := 16
    );
  port (
    wr_addr : in unsigned(gADDR_WIDTH-1 downto 0);
    rd_addr : in unsigned(gADDR_WIDTH-1 downto 0);

    datai : in  unsigned(gDATA_WIDTH-1 downto 0);
    datao : out unsigned(gDATA_WIDTH-1 downto 0);

    rd     : in std_logic;
    wr     : in std_logic;
    reset  : in std_logic;
    enable : in std_logic;
    clk    : in std_logic
    );

end auk_dspip_ctc_umts_mem;



architecture beh of auk_dspip_ctc_umts_mem is

  type   tMEMORY is array (0 to (2**gADDR_WIDTH)-1) of unsigned(gDATA_WIDTH-1 downto 0);
  signal mem                : tMEMORY;
  attribute ramstyle        : string;
  attribute ramstyle of mem : signal is "no_rw_check";


--    signal rd_addr_reg : unsigned(gADDR_WIDTH-1 downto 0);

begin  -- beh

    memory : process (clk)

    begin  -- process in_mem

        if clk'event and clk = '1' then
            if enable = '1' then
--                rd_addr_reg                            <= rd_addr;
                datao <= mem(to_integer(unsigned(rd_addr)));
                if wr = '1' then
                    mem(to_integer(unsigned(wr_addr))) <= datai;
                end if;
            end if;
        end if;
    end process memory;

    -- datao <= mem(to_integer(unsigned(rd_addr_reg)));
    --datao <= (others => '1');

end beh;

