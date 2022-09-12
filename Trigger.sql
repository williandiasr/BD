drop database db_Escola;
create database db_Escola;
use db_Escola;
set sql_safe_updates= 0;  

create table tb_Cliente(
ClienteId int primary key auto_increment,
CliNome varchar(150) not null,
CliEmail varchar(150) not null
);

delimiter $$
create procedure spInsertCliente (vCliNome varchar(150), vCliEmail varchar(150))
begin 
	insert into tb_Cliente(CliNome, CliEmail) values (vCliNome, vCliEmail);
end
$$

call spInsertCliente('Carlos', 'cc@escola.com');
call spInsertCliente('Davinho', 'inho@escola.com');
call spInsertCliente('Lindinha', 'lindi@escola.com');

create table tb_ClienteHistorico like tb_Cliente;
alter table tb_ClienteHistorico modify ClienteId int not null;
alter table tb_ClienteHistorico drop primary key;

alter table tb_ClienteHistorico add Situacao varchar (100);
alter table tb_ClienteHistorico add Momento datetime;

alter table tb_ClienteHistorico add constraint PK_Id_ClienteHistorico primary key(ClienteId,Situacao,Momento);

delimiter //
create trigger TRG_CliHistoricoInsert after insert on tb_Cliente 
	for each row
begin
	insert into tb_ClienteHistorico
		set ClienteId = new.ClienteId,
			CliNome = new.CliNome,
            CliEmail = new.CliEmail,
			Momento = current_timestamp(),
            Situacao = "Novo";
end;
//

insert into tb_Cliente (CliNome, CliEmail) values ('Tontinho', 'tonti@escola.com');
select * from tb_ClienteHistorico;

delimiter //
create trigger TGR_CliHistoricoUpdate after update on tb_Cliente
	for each row
begin
insert into tb_ClienteHistorico
		set ClienteId = old.ClienteId, 
			CliNome = old.CliNome,
            CliEmail = old.CliEmail,
			Momento = current_timestamp(),
            Situacao = "Antes";

	insert into tb_ClienteHistorico
		set ClienteId = new.ClienteId,
			CliNome = new.CliNome,
            CliEmail = new.CliEmail,
			Momento = current_timestamp(),
            Situacao = "Depois";
end;
//

delimiter $$
create procedure spInsertClienteUpdate (vClienteId int,vCliNome varchar(150), vCliEmail varchar(150))
begin 
	update tb_Cliente set CliNome = vCliNome, CliEmail = vCliEmail where ClienteId = vClienteId;
end
$$

call spInsertClienteUpdate(4, 'Muito Tontinho', 'tonti@escola.com');

select * from tb_Cliente;