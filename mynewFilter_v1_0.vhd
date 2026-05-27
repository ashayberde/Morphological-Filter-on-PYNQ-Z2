-- Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity Declaration
entity mynewFilter_v1_0 is
	generic (
		-- User parameters

		-- Parameters of AXI Slave Bus Interface
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of AXI Master Bus Interface
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32
	);
	port (
	switch : in unsigned (31 downto 0);
		-- AXI Slave Bus Interface
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tstrb	: in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;

		-- AXI Master Bus Interface
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end mynewFilter_v1_0;

-- Architecture Implementation
architecture arch_imp of mynewFilter_v1_0 is
    	-- component declaration
component mynewFilter_v1_0_S00_AXIS is
generic (
C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
	switch : in UNSIGNED(31 downto 0);
	S_AXIS_ACLK	: in std_logic;
	S_AXIS_ARESETN	: in std_logic;
	S_AXIS_TREADY	: out std_logic;
	S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
	S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
	S_AXIS_TLAST	: in std_logic;
	S_AXIS_TVALID	: in std_logic
	);
	end component mynewFilter_v1_0_S00_AXIS;
component mynewFilter_v1_0_M00_AXIS is
		generic (
C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
C_M_START_COUNT	: integer	:= 32
);
port (
switch : in UNSIGNED(31 downto 0);
M_AXIS_ACLK	: in std_logic;
M_AXIS_ARESETN	: in std_logic;
M_AXIS_TVALID	: out std_logic;
M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
M_AXIS_TLAST	: out std_logic;
M_AXIS_TREADY	: in std_logic
);
	end component mynewFilter_v1_0_M00_AXIS;
----- Filter component declarations:
component FIR_3x3 IS
 PORT (clk, rst: IN STD_LOGIC;
     switch : in UNSIGNED(31 downto 0);
    
        run: IN STD_LOGIC; --to compute the output
        x_input: IN SIGNED(8 DOWNTO 0); --, 
        y: OUT SIGNED(8 DOWNTO 0));
       
END component;

component FIR_3x3_1 IS
 PORT (clk, rst: IN STD_LOGIC;
     switch : in UNSIGNED(31 downto 0);
        run: IN STD_LOGIC; --to compute the output
        x_input: IN SIGNED(8 DOWNTO 0); --, 
        y: OUT SIGNED(17 DOWNTO 0));
       
END component;


    -- Signal Definitions
    signal run: std_logic;
    signal datain : signed(8 downto 0) := "000000000";
    signal out_signed_horizontal : signed(8 downto 0);
    signal out_signed_horizontal1 : signed(17 downto 0);

    signal out_signed_erosiondilation : signed(8 downto 0);
    signal out_signed_vertical1 : signed(17 downto 0);
        

    signal data_in : std_logic_vector(17 downto 0);
    signal data_out : std_logic_vector(7 downto 0);

begin
    -- Instantiation of the Erosion_Dilation
    Erosion_Dilation : FIR_3x3
    port map (
        clk => s00_axis_aclk,
        rst => s00_axis_aresetn,
        switch => switch,
        run => run,
        x_input => datain,
        y => out_signed_erosiondilation
  
    );
   Open_Close : FIR_3x3_1
    port map (
        clk => s00_axis_aclk,
        rst => s00_axis_aresetn,
        switch => switch,
        run => run,
        x_input => out_signed_erosiondilation(8 downto 0),
        y => out_signed_horizontal1
  
    );
  
    datain <= signed(s00_axis_tdata(8 downto 0));
    data_in <= std_logic_vector(resize(out_signed_horizontal1,18));
    data_out <= data_in(7 downto 0);
    m00_axis_tdata <= "000000000000000000000000" & data_out;

    -- Run signal comes from tvalid on the Slave interface
    run <= s00_axis_tvalid;

    -- Connect other AXI signals from Slave to Master
    m00_axis_tvalid <= s00_axis_tvalid;
    m00_axis_tstrb <= s00_axis_tstrb;
    m00_axis_tlast <= s00_axis_tlast;
    s00_axis_tready <= m00_axis_tready;

end arch_imp;
