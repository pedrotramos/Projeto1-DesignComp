LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- top_level: agrupa I/Os, decodificador e processador

ENTITY Relogio IS
  GENERIC (
    DATA_WIDTH : NATURAL := 8;
    ADDR_WIDTH : NATURAL := 8
  );

  PORT (
    -- Input ports
    CLOCK_50 : IN std_logic;
    SW       : IN std_logic_vector(7 DOWNTO 0);
    KEY      : IN std_logic_vector(3 DOWNTO 0);
	 -- Output ports
	 HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
  );
END ENTITY;
ARCHITECTURE rlt OF Relogio IS

  SIGNAL leituraSw, processador_decode : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
  SIGNAL barramento_entradaProcessador : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

  SIGNAL write_hex   : std_logic_vector(3 DOWNTO 0); -- displays so aceitam 4 bits
  SIGNAL load, store : std_logic; -- saem do processador, usados no decoder

  SIGNAL habilitaDsp    : std_logic_vector(5 DOWNTO 0);
  SIGNAL habilitaSw     : std_logic_vector(7 DOWNTO 0);
  SIGNAL habilitaBtempo : std_logic;
  SIGNAL clearBtempo    : std_logic;
  SIGNAL habilitaKey    : std_logic_vector(3 DOWNTO 0);

BEGIN

  Processador : ENTITY work.processador
    PORT MAP(
      clk         => CLOCK_50,
      dataIn      => barramento_entradaProcessador, -- tri-state base de tempo, chaves e botoes
      dadoDsp     => write_hex, -- dado a ser escrito displays
      load        => load,
      store       => store,
      outToDecode => processador_decode -- endereco para decodificador
    );

  Decodificador : ENTITY work.decodificador
    PORT MAP(
      dataIN         => processador_decode,
      store          => store,
      load           => load,
      habilitaDsp    => habilitaDsp,
      habilitaKey    => habilitaKey,
      habilitaSW     => habilitaSw,
      habilitaBtempo => habilitaBtempo,
      clearBtempo    => clearBtempo
    );
	 
	 
  -- I/O switches
  entradaChaves : ENTITY work.interfaceCHAVES
    PORT MAP(
      entrada  => SW(DATA_WIDTH - 1 DOWNTO 0),
      saida    => barramento_entradaProcessador,
      habilita => habilitaSw
    );

  -- I/O buttons
  entradaBotoes : ENTITY work.interfaceBOTOES
    PORT MAP(
      entrada  => KEY(3 DOWNTO 0),
      saida    => barramento_entradaProcessador,
      habilita => habilitaKey
    );

  -- I/O base de tempo	 
  interfaceBaseTempo : ENTITY work.divisorGenerico_e_Interface
    PORT MAP(
      clk              => CLOCK_50,
      habilitaLeitura  => habilitaBtempo,
      limpaLeitura     => clearBtempo,
      leituraUmSegundo => barramento_entradaProcessador,
		  selBaseTempo     => SW(0)
    );

  -- I/O displays
  Displays : ENTITY work.interfaceDISPLAYS
    PORT MAP(
      dataIN => write_hex,
      enable => habilitaDsp,
      clk    => CLOCK_50,
		H0     => HEX0,
		H1     => HEX1,
		H2     => HEX2, 
		H3     => HEX3,
		H4     => HEX4,
		H5     => HEX5
    );
END ARCHITECTURE;