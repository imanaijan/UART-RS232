library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity top is
	port(
		clk_i_near: in std_logic;
		clk_i_far: in std_logic;
		reset_near_i: in std_logic;
		reset_far_i: in std_logic;
		
		duration_i: in std_logic_vector(15 downto 0); --длительность
		load_duration_i: in std_logic;                --сигнал загрузки в ближний трансмиттер и ресивер
		
		data_byte_near_i: in std_logic_vector(7 downto 0); --данные, которые будем передавать
		load_data_near_i: in std_logic;
		
		data_byte_far_i: in std_logic_vector(7 downto 0); --данные, которые будем передавать
		load_data_far_i: in std_logic;

		data_byte_near_o: out std_logic_vector(7 downto 0); --данные, которые получили обратно через цикл
		data_ready_near_o: out std_logic; --признак получения данных
		
		data_byte_far_o: out std_logic_vector(7 downto 0); --данные, которые получили обратно через цикл
		data_ready_far_o: out std_logic; --признак получения данных

		duration_particullary_calculated_far_o: out std_logic; --признак того, что прошел один цикл рассчета длительности
		duration_calculated_far_o: out std_logic;              --признак того, что длительность рассчитана 

		duration_particullary_calculated_near_o: out std_logic; --признак того, что прошел один цикл рассчета длительности
		duration_calculated_near_o: out std_logic              --признак того, что длительность рассчитана 
    );
end top;

architecture top_arch of top is
	component reciver
	port(
		clk_i: in std_logic;   --синхросигнал
		reset_i: in std_logic; --асинхронный сброс

		duration_o: out std_logic_vector(15 downto 0); --рассчитанная длительность
		duration_particullary_calculated_o: out std_logic;
		duration_calculated_o: out std_logic;            --признак того, что длительность рассчитана 

		data_i: in std_logic;                          --данные, передающиеся по разряду
		data_byte_o: out std_logic_vector(7 downto 0); --результирующие данные
		data_ready_o: out std_logic                    --флаг готовности данных
    );
	end component;
	
	component transmitter
	port(
		clk_i: in std_logic;   --синхросигнал
		reset_i: in std_logic; --асинхронный сброс
		duration_i: in std_logic_vector(15 downto 0); --длительность такта работы уарт
		load_duration_i: in std_logic;                --сигнал загрузки длительности

		data_byte_i: in std_logic_vector(7 downto 0); --байт данных, который будем передавать
		load_data_i: in std_logic;                    --сигнал загрузки данных
		
		data_o: out std_logic                         --передача бита через уарт
    );
	end component;
	
	signal data_from_near_to_far: std_logic;
	
	signal calculated_duration_r: std_logic_vector(15 downto 0);
	signal duration_calculated_far: std_logic;
	
	signal data_from_far_to_near: std_logic;
	
begin
	near_transmitter: transmitter
	port map(
		clk_i => clk_i_near,
		reset_i => reset_near_i,
		duration_i => duration_i,
		load_duration_i => load_duration_i,

		data_byte_i => data_byte_near_i,
		load_data_i => load_data_near_i,
		
		data_o => data_from_near_to_far
	);
	
	near_reciver: reciver
	port map(
		clk_i => clk_i_near,
		reset_i => reset_near_i,

		duration_o => open,
		duration_particullary_calculated_o => duration_particullary_calculated_near_o,
		duration_calculated_o => duration_calculated_near_o, 

		data_i => data_from_far_to_near,
		data_byte_o => data_byte_near_o,
		data_ready_o => data_ready_near_o
	);

	duration_calculated_far_o <= duration_calculated_far;
	
	far_transmitter: transmitter
	port map(
		clk_i => clk_i_far,
		reset_i => reset_far_i,
		duration_i => calculated_duration_r,
		load_duration_i => duration_calculated_far,

		data_byte_i => data_byte_far_i,
		load_data_i => load_data_far_i,
		
		data_o => data_from_far_to_near
	);
	

	far_reciver: reciver
	port map(
		clk_i => clk_i_far,
		reset_i => reset_far_i,

		duration_o => calculated_duration_r,
		duration_particullary_calculated_o => duration_particullary_calculated_far_o,
		duration_calculated_o => duration_calculated_far, 

		data_i => data_from_near_to_far,
		data_byte_o => data_byte_far_o,
		data_ready_o => data_ready_far_o
	);
	

end architecture top_arch;