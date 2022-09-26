set sql_safe_updates= 0; 
drop database dbDistribuidora;
create database dbDistribuidora;
use dbDistribuidora;

create table tbCliente(
	IdCli int primary key auto_increment,
    NomeCli varchar(200) not null,
    NumEnd numeric(6) not null,
    CompEnd varchar(50),
    CepCli numeric(8) not null
);

create table tbClientePF(
	CPF numeric(11) primary key,
    RG numeric(9) not null,
    RG_Dig char(1) not null,
    Nasc date not null,
    IdCli int unique not null 
); 

create table tbClientePJ(
	CNPJ numeric(14) primary key,
    IE numeric(11) unique,
    IdCli int unique not null 
);

create table tbProduto(
    CodigoBarras numeric(14) primary key,
    NomeProd varchar(200) not null,
    Valor decimal(5,2) not null,
    Qtd int
);

create table tbVenda(
	CodigoVenda numeric(10) primary key auto_increment,
    DataVenda date default(current_timestamp()),
    ValorTotal decimal(6,2) not null,
    QtdTotal int not null,
    NotaFiscal int,
    IdCli int not null
);

create table tbNotaFiscal(
	NotaFiscal int primary key,
    TotalNota decimal(7,2) not null,
    DataEmissao date not null
);

create table tbItemVenda(
	CodigoVenda numeric(10) auto_increment,
    CodigoBarras numeric(14),
    ValorItem decimal(5,2) not null,
    Qtd int not null,
    primary key(CodigoVenda,CodigoBarras)
);

create table tbFornecedor(
	IdFornecedor int auto_increment primary key,
    CNPJ decimal(14,0) not null unique,
    NomeFornecedor varchar(100) not null,
    telefone numeric(11)
);

create table tbCompra(
	NotaFiscalPedido int primary key,
    DataCompra date not null,
    ValorTotal decimal (10,2) not null,
    QtdTotal int not null,
    IdFornecedor int
);

create table tbCompraProduto(
	NotaFiscalPedido int,
    CodigoBarras numeric(14),
    Qtd int,
    ValorItem decimal(10,2),
    primary key(NotaFiscalPedido,CodigoBarras)
);

create table tbEndereco(
	CEP numeric(8) primary key,
    Logradouro varchar(200),
    IdBairro int not null,
    IdCidade int not null,
    IdUF int not null
);

create table tbBairro(
    IdBairro int primary key auto_increment,
    Bairro varchar(200) not null
);

create table tbCidade(
    IdCidade int primary key auto_increment,
    Cidade varchar(200) not null
);

create table tbUF(
    IdUF int primary key auto_increment,
    UF varchar(200) not null
);

alter table tbCliente add foreign key (CepCli) references tbEndereco(CEP);

alter table tbClientePF add foreign key (IdCli) references tbCliente(IdCli);

alter table tbClientePJ add foreign key (IdCli) references tbCliente(IdCli);

alter table tbVenda add foreign key (NotaFiscal) references tbNotaFiscal(NotaFiscal);
alter table tbVenda add foreign key (IdCli) references tbCliente(IdCli);


alter table tbItemVenda add foreign key (CodigoVenda) references tbVenda(CodigoVenda);
alter table tbItemVenda add foreign key (CodigoBarras) references tbProduto(CodigoBarras);

alter table tbCompra add foreign key (IdFornecedor) references tbFornecedor(IdFornecedor);

alter table tbCompraProduto add foreign key (NotaFiscalPedido) references tbCompra(NotaFiscalPedido);
alter table tbCompraProduto add foreign key (CodigoBarras) references tbProduto(CodigoBarras);

alter table tbEndereco add foreign key (IdBairro) references tbBairro(IdBairro);
alter table tbEndereco add foreign key (IdCidade) references tbCidade(IdCidade);
alter table tbEndereco add foreign key (IdUF) references tbUF(IdUF);

 -- drop procedure spInsertCidade; -- Salvação

delimiter $$
create procedure spSelectErro(vRegistro varchar(50),vExiste enum("já","não"))
begin
	select concat("O registro de: ",vRegistro," ",vExiste," existe na tabela.") as "Erro de insert!";
end
$$

delimiter $$
create procedure spInsertFornecedor (vCNPJ decimal(14,0), vNomeFornecedor varchar(100) , vTelefone numeric(11))
begin
	insert into tbFornecedor(CNPJ, NomeFornecedor, telefone) values(vCNPJ, vNomeFornecedor, vTelefone);
end
$$

describe tbCidade;
delimiter $$
create procedure spInsertCidade(vCidade varchar(200))
begin
	insert into tbCidade(Cidade) values (vCidade);
end
$$

describe tbUF;
delimiter $$
create procedure spInsertUF(vEstado varchar(200))
begin
	insert into tbUF(UF) values (vEstado);
end
$$

describe tbBairro;
delimiter $$
create procedure spInsertBairro(vBairro varchar(200))
begin
	insert into tbBairro(Bairro) values (vBairro);
end
$$

describe tbProduto;
delimiter $$
create procedure spInsertProduto(vCodigoBarras decimal(14,0), vNome varchar(200), vValor decimal(5,2), vQtd int)
begin
	insert into tbProduto(CodigoBarras,NomeProd,Valor,Qtd) values (vCodigoBarras,vNome,vValor,vQtd);
end
$$

describe tbEndereco;
delimiter $$
create procedure spInsertEndereco(vCep decimal(8,0),vLogradouro varchar(200),vBairro varchar(200), vCidade varchar(200), vEstado varchar(200))
begin
	if not exists(select * from tbUf where UF = vEstado) then
		call spInsertUf(vEstado);
	end if;
    if not exists(select * from tbCidade where Cidade = vCidade) then
		call spInsertCidade(vCidade);
	end if;
    if not exists(select * from tbBairro where Bairro = vBairro) then
		call spInsertBairro(vBairro);
	end if;
	if not exists(select * from tbEndereco where Cep = vCep) then
		set @Bairro = (select IdBairro from tbBairro where Bairro = vBairro);
		set @Cidade = (select IdCidade from tbCidade where Cidade = vCidade);
		set @Estado = (select IdUf from tbUF where Uf = vEstado);
		insert into tbEndereco(CEP,Logradouro,IdBairro,IdCidade,IdUF) values (vCep,vLogradouro,@Bairro,@Cidade,@Estado);
	else 
			call spSelectErro("Endereço","já");
	end if;
end
$$

call spInsertFornecedor(1245678937123, "Revenda Chico Loco", 11934567897);
call spInsertFornecedor(1345678937123, "José Faz Tudo S/A", 11934567898);
call spInsertFornecedor(1445678937123, "Vadalto Entregas", 11934567899);
call spInsertFornecedor(1545678937123, "Astrogildo das Estrelas", 11934567800);
call spInsertFornecedor(1645678937123, "Amoroso e Doce", 11934567801);
call spInsertFornecedor(1745678937123, "Marcelo Dedal", 11934567802);
call spInsertFornecedor(1845678937123, "Franciscano Cachaça", 11934567803);
call spInsertFornecedor(1945678937123, "Joãozinho Chupeta", 11934567804);

select * from tbFornecedor;

call spInsertCidade("Rio de Janeiro");
call spInsertCidade("São Carlos");
call spInsertCidade("Campinas");
call spInsertCidade("Franco da Rocha");
call spInsertCidade("Osasco");
call spInsertCidade("Pirituba");
call spInsertCidade("Ponta Grossa");
call spInsertCidade("São Paulo");
call spInsertCidade("Barra Mansa");

select * from tbCidade;

call spInsertUF("SP");
call spInsertUF("RJ");
call spInsertUF("RS");

select * from tbUF;

call spInsertBairro("Aclimação");
call spInsertBairro("Capão Redondo");
call spInsertBairro("Pirituba");
call spInsertBairro("Liberdade");
call spInsertBairro("Lapa");
call spInsertBairro("Penha");
call spInsertBairro("Consolação");
call spInsertBairro("Barra Funda");

select * from tbBairro;

call spInsertProduto(12345678910111,'Rei de Papel Mache',54.61,120);
call spInsertProduto(12345678910112,'Bolinha de Sabão',100.45,120);
call spInsertProduto(12345678910113,'Barro Bate Bate',44.00,120);
call spInsertProduto(12345678910114,'Bola Furada',10.00,120);
call spInsertProduto(12345678910115,'Maçã Laranja',99.44,120);
call spInsertProduto(12345678910116,'Boneco do Hitler',124.00,200);
call spInsertProduto(12345678910117,'Farinha de Surui',50.00,200);
call spInsertProduto(12345678910118,'Zelador de Cemitério',24.50,100);

select * from tbProduto;

call spInsertEndereco(12345050, "Rua da Federal", "Lapa", "São Paulo", "SP");
call spInsertEndereco(12345051, "Av Brasil", "Lapa", "Campinas", "SP");
call spInsertEndereco(12345052, "Rua Liberdade", "Consolação", "São Paulo", "SP");
call spInsertEndereco(12345053, "Av Paulista", "Penha", "Rio de Janeiro", "RJ");
call spInsertEndereco(12345054, "Rua Ximbú", "Penha", "Rio de Janeiro", "RJ");
call spInsertEndereco(12345055, "Rua Piu X1", "Penha", "Campinas", "SP");
call spInsertEndereco(12345056, "Rua chocolate", "Aclimação", "Barra Mansa", "RJ");
call spInsertEndereco(12345057, "Rua Pão na Chapa", "Barra Funda", "Ponta Grossa", "RS");

Select * from tbEndereco;
Select * from tbBairro;
Select * from tbCidade;
select * from tbUf;

-- exe 7
delimiter $$
 create procedure spInsertClientePf(vNomeCli varchar(200), vNumEnd decimal(6,0), vCompEnd varchar(50), vCepCli decimal(8,0), vCpf decimal(11,0), vRg decimal(9,0), vRg_Dig char(1), vNasc date,vLogradouro varchar(200),vBairro varchar(200), vCidade varchar(200), vEstado varchar(200))
 begin
	if not exists(select * from tbEndereco where CEP = vCepCli) then
		call spInsertEndereco(vCepCli,vLogradouro,vBairro,vCidade, vEstado);
	end if;
		if not exists(select * from tbClientePf where CPF = vCPF) then
			insert into tbCliente(NomeCli,NumEnd,CompEnd,CepCli) values (vNomeCli,vNumEnd,vCompEnd,vCepCli);
			set @idCli = (select max(IdCli) from tbCliente);
			insert into tbClientePf(CPF, RG, RG_Dig, Nasc, IdCli) values (vCPF, vRG, vRG_Dig, vNasc, @IdCli);
		else
			call spSelectErro("Cliente","já");
    end if;
 end
 $$

call spInsertClientePf("Pimpão",325,null,12345051,12345678911,12345678,"0","2000-10-12","Av. Brasil","Lapa","Campinas","SP");
call spInsertClientePf("Disney Chaplin",89,"Ap. 12",12345053,12345678912,12345679,"0","2000-11-21","Av. Brasil","Penha","Rio de Janeiro","RJ");
call spInsertClientePf("Marciano",744,null,12345054,12345678913,12345680,"0","2000-06-01","Rua Ximbu","Penha","Rio de Janeiro","RJ");
call spInsertClientePf("Lança Perfume",128,null,12345059,12345678914,12345681,"X","2000-04-05","Rua veia","Jardim Santa Isabel","Cuiabá","MT");
call spInsertClientePf("Remédio Amargo",2585,null,12345058,12345678915,12345682,"0","2000-07-15","Av Nova","Jardim Santa Isabel","Cuiabá","MT");

describe tbEndereco;
select * from tbCliente;
select * from tbClientePF;


-- exe 8
delimiter $$
 create procedure spInsertClientePJ(vNomeCli varchar(200),vCNPJ decimal(14,0),vIE decimal(11,0), vCepCli decimal(8,0), vLogradouro varchar(200), vNumEnd decimal(6,0), vCompEnd varchar(50),vBairro varchar(200), vCidade varchar(200), vEstado varchar(200)) 
 begin
	if not exists(select * from tbEndereco where CEP = vCepCli) then
		call spInsertEndereco(vCepCli,vLogradouro,vBairro,vCidade, vEstado);
	end if;
		if not exists(select * from tbClientePJ where CNPJ = vCNPJ) then
			insert into tbCliente(NomeCli,NumEnd,CompEnd,CepCli) values (vNomeCli,vNumEnd,vCompEnd,vCepCli);
			set @idCli = (select max(IdCli) from tbCliente);
			insert into tbClientePJ(CNPJ, IE, idCli) values (vCNPJ, vIE,@IdCli);
		else
			call spSelectErro("Cliente","já");
		end if;
 end
 $$
 
call spInsertClientePj("Paganada",12345678912345,98765432198,12345051,"Av. Brasil",159,null,"Lapa","Campinas","SP");
call spInsertClientePj("Caloteando",12345678912346,98765432199,12345053,"Av. Paulista",69,null,"Penha","Rio de Janeiro","RJ");
call spInsertClientePj("Semgrana",12345678912347,98765432100,12345060,"Rua dos Amores",189,null,"Sei lá","Recife","PE");
call spInsertClientePj("Cemreais",12345678912348,98765432101,12345060,"Rua dos Amores",5024,"Sala 23","Sei lá","Recife","PE");
call spInsertClientePj("Durango",12345678912349,98765432102,12345060,"Rua dos Amores",1254,null,"Sei lá","Recife","PE");

select * from tbCliente;
select * from tbClientePf;
select * from tbClientePJ;


-- exe 9
delimiter $$
create procedure spInsertCompra(vNotaFiscal int,vFornecedor varchar(100), vDataCompra char(10), vCodigoBarras decimal(14,0), vValorItem decimal(5,2), vQtd int,vQtdTotal int,vValorTotal decimal(10,2))
begin
	declare vDataFormatada date;
	if not exists(select * from tbCompra where NotaFiscalPedido = vNotaFiscal) then
        set @Fornecedor = (select IdFornecedor from tbFornecedor where NomeFornecedor = vFornecedor);
        set vDataFormatada = str_to_date(vDataCompra, '%d/%m/%Y');
		insert into tbCompra(NotaFiscalPedido,DataCompra,ValorTotal,QtdTotal,IdFornecedor) values (vNotaFiscal,vDataFormatada,vValorTotal,vQtdTotal,@Fornecedor);
    end if;
    if not exists(select * from tbCompraProduto where NotaFiscalPedido = vNotaFiscal and CodigoBarras = vCodigoBarras) then
    insert into tbCompraProduto(NotaFiscalPedido,CodigoBarras,Qtd,ValorItem) values (vNotaFiscal,vCodigoBarras,vQtd,vValorItem);
    else
		call spSelectErro('Compra desse produto','já');
	end if;
end
$$

call spInsertCompra(8459,"Amoroso e Doce",'01/05/2018',12345678910111,22.22,200,700, 21944.00);
call spInsertCompra(2482,"Revenda Chico Loco",'22/04/2020',12345678910112,40.50,180,180,7290.00);
call spInsertCompra(21653,"Marcelo Dedal",'12/07/2020',12345678910113,3.00,300,300,900.00);
call spInsertCompra(8459,"Amoroso e Doce",'04/12/2020',12345678910114,35.00,500,700,21944.00);
call spInsertCompra(156354,"Revenda Chico Loco",'23/11/2021',12345678910115,54.00,350,350,18900.00);

select * from tbCompra;


-- exe 10
delimiter $$
create procedure spInsertVenda(vCliente varchar(100), vCodigoBarras decimal(14,0), vQtd int)
begin
	if exists (select * from tbProduto,tbCliente where CodigoBarras = vCodigoBarras and NomeCli = vCliente) then
		if not exists(select * from tbVenda where IdCli = vCliente) then
			set @DataVenda = current_timestamp();
			set @idCliente = (select IdCli from tbCliente where NomeCli = vCliente);
			insert into tbVenda(IdCli,CodigoBarras,QtdTotal) values (@idCliente,vCodigoBarras,vQtd);
		end if;
		if not exists(select * from tbItemVenda where @IdCli = vCliente and CodigoBarras = vCodigoBarras) then
			insert into tbItemVenda(CodigoBarras,QtdTotal) values (vCliente,vCodigoBarras,vQtd);
        else
			call spSelectErro('Venda desse produto','já');
		end if;
    end if;
	if not exists(select * from tbCliente where NomeCli = vCliente) then call spSelectErro("Cliente","não"); end if;
	if not exists(select * from tbProduto where CodigoBarras = vCodigoBarras) then call spSelectErro("Produto","não"); end if;
end
$$

drop procedure spInsertVenda;
call spInsertVenda("Pimpão",12345678910111,1);
call spInsertVenda(2,"Lança Perfume","22/08/2022",12345678910112,54.61,1,54.61,null);
call spInsertVenda(3,"Pimpão","22/08/2022",12345678910113,100.45,2,200.90,null);
select * from tbVenda;
select * from tbItemVenda;
describe tbVenda;

-- exe 11
delimiter $$
create procedure spInsertNotaFiscal(vNotaFiscal int, vCliente varchar(100), vDataEmissao char(10))
begin
	declare vDataFormatada date;
	set vDataFormatada = str_to_date(vDataEmissao, '%d/%m/%Y');
    set @idCliente = (select idCli from tbCliente where NomeCli = vCliente);
	set @totalVenda = (select sum(ValorTotal) from tbVenda where idCli = @idCliente and DataVenda = vDataFormatada);
    if (@totalVenda is null) then call spSelectErro("Venda","não");
    else
		if not exists(select * from tbNotaFiscal where NotaFiscal = vNotaFiscal) then
			insert into tbNotaFiscal(NotaFiscal,TotalNota,DataEmissao) values (vNotaFiscal,@totalVenda,vDataFormatada);
		else
			update tbNotaFiscal set TotalNota = @totalVenda where NotaFiscal = vNotaFiscal;
        end if;
	end if;
end
$$

 describe tbVenda;
describe tbNotaFiscal;

call spInsertNotaFiscal(359,"Pimpão","22/08/2022");
call spInsertNotaFiscal(360,"Lança Perfume","22/08/2022");

select * from tbNotaFiscal;
select * from tbFornecedor;
select * from tbVenda;
select * from tbItemVenda;
select * from tbCompra;
select * from tbCliente;
select * from tbClientePf;
select * from tbClientePJ;

-- exe 12


call spInsertProduto(12345678910130,"Camiseta de Poliester","35.61", "100");
call spInsertProduto(12345678910131,"Blusa Frio Moletom","200.00", "100");
call spInsertProduto(12345678910132,"Vestido Decote Redondo","144.00", "50");
select * from tbProduto;

-- exe 13

delimiter $$
create procedure spDeleteProduto(vCodigoBarras decimal(14,0))
begin
	delete from tbProduto where CodigoBarras = vCodigoBarras;
end
$$

call spDeleteProduto(12345678910116);
call spDeleteProduto(12345678910117);

-- exe 14

delimiter $$
create procedure spUpdateProduto(vNomeProd varchar(200), vValor decimal(5,2), vCodigoBarras decimal(14,0))
begin
	update tbProduto set NomeProd = vNomeProd, Valor = vValor where CodigoBarras = vCodigoBarras ;
end
$$


call spUpdateProduto("Rei de Papel Mache",64.50, 12345678910111);
call spUpdateProduto("Bolinha de Sabão",120.00, 12345678910112);
call spUpdateProduto("Carro Bate Bate",64.00, 12345678910113);

-- exe 15

delimiter $$
create procedure spSelectProduto()
begin
	select * from tbProduto;
end
$$
call spSelectProduto;

-- exe 16

create table tb_ProdutoHistorico like tbProduto;

-- exe 17

alter table tb_ProdutoHistorico add Ocorrencia varchar(20); 
alter table tb_ProdutoHistorico add Atualizacao datetime;
describe tb_ProdutoHistorico;

-- exe 18

alter table tb_ProdutoHistorico modify CodigoBarras numeric(14) not null;
alter table tb_ProdutoHistorico drop primary key;
alter table tb_ProdutoHistorico add constraint PK_Id_ProdutoHistorico primary key(CodigoBarras,Atualizacao,Ocorrencia);

-- exe 19

delimiter //
create trigger TRG_ProdHistoricoInsert after insert on tbProduto 
	for each row
begin
	insert into tb_ProdutoHistorico
		set CodigoBarras = new.CodigoBarras,
			NomeProd = new.NomeProd,
            Valor = new.Valor,
            Qtd = new.Qtd,
            Atualizacao = current_timestamp(),
            Ocorrencia = "Novo";
end;
//

call spInsertProduto(12345678910119,"Agua mineral",1.99, 500);
select * from tb_ProdutoHistorico;

-- exe 20

delimiter //
create trigger TGR_ProdHistoricoUpdate after update on tbProduto
	for each row
begin
insert into tb_ProdutoHistorico
		set CodigoBarras = new.CodigoBarras,
			NomeProd = new.NomeProd,
            Valor = new.Valor,
            Qtd = new.Qtd,
            Atualizacao = current_timestamp(),
            Ocorrencia = "Atualizado";
end
//



call spUpdateProduto("Agua mineral",2.99, 12345678910119);
call spUpdateProduto("Boneca de Plastico", 101.00, 12345678910199);



-- exe 21

select * from tbProduto;

-- ex 22

call spInsertVenda(4,"Disney Chaplin","26/08/2022",12345678910111,64.50,1,65.50,null);
select * from tbCliente;

-- ex 23

select * from tbVenda order by IdCli LIMIT 1 OFFSET 2;


-- exe 24

select * from tbItemVenda order by CodigoVenda desc LIMIT 1 ;


-- exe 25

delimiter $$
create procedure spUpdateCliente(vNomeCli varchar(200), vNumEnd decimal(6,0), vCompEnd varchar(50), vCepCli decimal(8,0))
begin
	update tbCliente set NomeCli = vNomeCli, NumEnd = vNumEnd, CompEnd = vCompEnd where CepCli = vCepCli ;
end
$$

call spUpdateCliente ("Disney Chapin", 89,"Ap. 12",12345053);

select * from tbCliente;

-- exe 26

delimiter //
create trigger TRG_UpdateProdutoQtd after insert on tbItemVenda
for each row
begin
	update tbProduto set Qtd = Qtd - new.Qtd where CodigoBarras = new.CodigoBarras;
end
//

-- exe 27

select * from tbProduto where CodigoBarras = 12345678910114;
call spSelectProduto();
call spInsertVenda(5, "Paganada", "26/09/2022",12345678910114, 10.00, 15, 150.00, null);

-- exe 28
call spSelectProduto();

-- exe 29

delimiter //
create trigger TRG_UpdateCompraQtd after insert on tbCompraProduto
for each row
begin
	update tbProduto set Qtd = Qtd + new.Qtd where CodigoBarras = new.CodigoBarras;
end
//

select * from tbCompra;
show tables;

-- exe 30
call spInsertCompra(10548,"Amoroso e Doce","10/09/2022", 12345678910111, 40.00, 100, 100, 4000.00);

-- exe 31

call spSelectProduto();
