---Triggers
---Comprueba que el nombre sea unico en la Tabla Componente
create trigger insercionComponente on Componente for insert
as 
if(select count(*) from inserted,Componente where inserted.nombreComponente = Componente.nombreComponente) >1
begin 
	rollback transaction 
	print 'El componente ya existe'
end 
else 
	print 'El componente ha sido registrado'

---Comprueba que el  nombre sea unico en la Tabla Diagnostico
create trigger insercionDiagnostico on Diagnostico for insert
as 
if(select count(*) from inserted,Diagnostico where inserted.nombreDiagnostico = Diagnostico.nombreDiagnostico) >1
begin 
	rollback transaction 
	print 'El diagnostico ya existe'
end 
else 
	print 'El diagnostico ha sido registrado'

---Comprueba que el nombre sea unico en la Tabla EspecialidadPersonal
create trigger insercionEspecialidad on EspecialidadPersonal for insert
as 
if(select count(*) from inserted,EspecialidadPersonal where inserted.descripcionEspecialidad= EspecialidadPersonal.descripcionEspecialidad) >1
begin 
	rollback transaction 
	print 'La especialidad ya existe'
end 
else 
	print 'La descripcion de la especialidad ha sido registrada'

---Comprueba que el nombre sea unico en la Tabla Medicamento
create trigger insercionMedicamento on Medicamento for insert
as 
if(select count(*) from inserted,Medicamento where inserted.nombre= Medicamento.nombre) >1
begin 
	rollback transaction 
	print 'El medicamento ya existe'
end 
else 
	print 'El medicamento ha sido registrado'
---Comprueba que el nombre sea unico en la Tabla Medicamento
create trigger insercionPaciente on Paciente for insert
as 
if(select count(*) from inserted,Paciente where inserted.nombrePaciente= Paciente.nombrePaciente) >1
begin 
	rollback transaction 
	print 'El paciente ya existe'
end 
else 
	print 'El paciente ha sido registrado'
---Comprueba que el nombre sea unico en la Tabla Personal
create trigger insercionPersonal on Personal for insert
as 
if(select count(*) from inserted,Personal where inserted.nombrePersonal= Personal.nombrePersonal) >1
begin 
	rollback transaction 
	print 'El colaborador ya existe'
end 
else 
	print 'El colaborador ha sido registrado'
---Comprueba que el nombre sea unico en la Tabla Presentacion
create trigger insercionPresentacion on Presentacion for insert
as 
if(select count(*) from inserted,Presentacion where inserted.nombrePresentacion= Presentacion.nombrePresentacion) >1
begin 
	rollback transaction 
	print 'La presentacion ya existe'
end 
else 
	print 'La presentacion ha sido registrado'

--- Actualizar las camas
create trigger actualizarEstadoCama on Hospitalizacion after insert
as begin
	declare @idTemp varchar(15)
	select @idTemp = idCama from inserted
	UPDATE Cama sET idEstadoCama = '0001' where idCama = @idTemp
end

---**Consultas**----
--1. Cantidad de personal que se encuentra laborando en el Hospital; se debe mostrar su nombre, fecha de nacimiento y Telefono de emergencias. 
select Personal.nombrePersonal, Personal.fechaNacimiento,Personal.telefonoEmergencia from Personal 
full join EstadoPersonal on Personal.idEstadoPersonal = EstadoPersonal.idEstadoPersonal 
where EstadoPersonal.descripcionEstadoPersonal = 'Activo'
--2. La cantidad de camas que no se encuentran disponibles, se debe mostrar su habitacion y el paciente que la ocupa
select Paciente.nombrePaciente, Paciente.apellidoPaterno, Paciente.apellidoMaterno,cama.nroCama, cama.nroHabitacion from ((cama inner  join EstadoCama on Cama.idEstadoCama = estadoCama.idEstadoCama) full join Hospitalizacion on
Hospitalizacion.idCama = Cama.idCama) inner join Paciente on Hospitalizacion.idPaciente = Paciente.idPaciente
where estadoCama.descripcionEstadoCama = 'En uso' 
--3. Cantidad de medicamentos disponibles
select COUNT(EstadoMedicamento.idEstadoMedicamento) as [Medicamentos disponibles] from (EstadoMedicamento inner join Medicamento on Medicamento.idEstadoMedicamento = Medicamento.idEstadoMedicamento)
where EstadoMedicamento.descripcionEstadoMedicamento = 'vigente'
--- 4. Nombre y marca de los medicamentos caducados 
select Medicamento.nombre as [Medicamentos Caducados], Medicamento.marca from (EstadoMedicamento inner join Medicamento on Medicamento.idEstadoMedicamento = Medicamento.idEstadoMedicamento)
where EstadoMedicamento.descripcionEstadoMedicamento = 'Caducado' and Medicamento.marca is not null
--5. Cantidad de pacientes en el día sabado
select count( descripcionTipoCita) as [Pacientes Sábado]
from TipoCita  where descripcionTipoCita  like '%Sábado a las%' 
---6. Cantidad de personal con la misma especialidad, se debe mostrar la cantidad y la especialidad. 
select count(descripcionEspecialidad) as [Cantidad de especialistas], descripcionEspecialidad as [Especialidad]
from EspecialidadPersonal where descripcionEspecialidad in (select descripcionEspecialidad from EspecialidadPersonal
group by descripcionEspecialidad having   count(descripcionEspecialidad)>=1  )
group by descripcionEspecialidad
--7. Nombre del personal que ingreso a las 9am y salió a las 11pm, se debe mostrar su Hora salida y entrada. 
select Personal.nombrePersonal as [Personal], EntradaPersonal.horaEntrada, SalidaPersonal.horaSalida from (EntradaPersonal full join Personal on EntradaPersonal.idPersonal = Personal.idPersonal) full join SalidaPersonal
on Personal.idPersonal = SalidaPersonal.idPersonal where EntradaPersonal.horaEntrada >= '9:00:00' and SalidaPersonal.horaSalida<='22:00:00'
--8. El nombre de las personas y su numero de habitacion en las que se encuentran 
select Paciente.nombrePaciente, Habitacion.nroHabitacion from ((Hospitalizacion full join Paciente on Hospitalizacion.idPaciente = Paciente.idPaciente) full join
cama on Hospitalizacion.idCama = cama.idCama) full join Habitacion on cama.nroHabitacion = Habitacion.nroHabitacion where
nombrePaciente is not null
-- 9. El nombre del medicamento y paciente en donde la cantidad de dosis del medicamento sea mayor a 2(ordenados por nombres)
select Paciente.nombrePaciente, Paciente.apellidoPaterno,  Medicamento.nombre from 
(((recetaMedicaMedicamento full join Medicamento 
on recetaMedicaMedicamento.idMedicamento = Medicamento.idMedicamento)full join RecetaMedica 
on RecetaMedica.idRecetaMedica = recetaMedicaMedicamento.idRecetaMedica) full join Paciente 
on RecetaMedica.idPaciente = Paciente.idPaciente) where recetaMedicaMedicamento.cantidad >2
order by Paciente.nombrePaciente
--10. El total de medicamentos que tiene el hospital 
select sum(stock) as [Total de Medicamentos] from MedicamentoProveedor
---11. La dosis sea menor a 4 necesita cada paciente y el doctor que la receto
select Paciente.nombrePaciente, recetaMedicaMedicamento.cantidad as [Dosis], Personal.nombrePersonal as [Fue atendido por]from ((Paciente full join RecetaMedica on RecetaMedica.idPaciente = Paciente.idPaciente) full join Personal 
on RecetaMedica.idPersonal = Personal.idPersonal) full join recetaMedicaMedicamento on recetaMedicaMedicamento.idRecetaMedica = RecetaMedica.idRecetaMedica
where recetaMedicaMedicamento.cantidad <4
-- 12. La cantidad de personas que atiende un doctor
select count(RecetaMedica.idRecetaMedica) as [Cantidad de Veces atendidas], Paciente.nombrePaciente, Personal.nombrePersonal 
from ((RecetaMedica inner join Personal on RecetaMedica.idPersonal=Personal.idPersonal) inner join Paciente
on Paciente.idPaciente = RecetaMedica.idPaciente) inner join Cita on Cita.idPaciente = Paciente.idPaciente
where RecetaMedica.idPaciente = Paciente.idPaciente and RecetaMedica.idPersonal = Personal.idPersonal 
group by Paciente.nombrePaciente, Personal.nombrePersonal
--13. El diagnositco  y conclusion que atribuye cada doctor a su paciente entre los años 2017 y  2019 en orden alfabetico
select Paciente.nombrePaciente, cita.fecha_Cita, Diagnostico.descripcionDiagnostico, ConclusionCita.descripcionConclusion from (((Cita full join Paciente on Cita.idPaciente = Paciente.idPaciente) full join ConclusionCita 
on cita.idConclusionCita = ConclusionCita.idConclusionCita) full join DiagnosticoConclusionCita on 
DiagnosticoConclusionCita.idConclusionCita = ConclusionCita.idConclusionCita) full join Diagnostico on
Diagnostico.idDiagnostico = DiagnosticoConclusionCita.idDiagnostico where cita.fecha_Cita between '2017-01-01' and '2019-12-31'
order by Paciente.nombrePaciente
--14. La cantidad mayor a 180 que reparte cada proveedor
select DetallePedido.cantidad [Cantidad Repartir], Proveedor.nombre as [Nombre Proveedor] from (DetallePedido inner join Pedido on DetallePedido.idPedido = Pedido.idPedido) 
inner join Proveedor on Pedido.idProveedor = Proveedor.idProveedor where DetallePedido.cantidad >160
-- 15. El costo total por la paga de medicamentos 
select sum(cantidad * precioUnitario) as [La cantidad total a pagar es] from DetallePedido
-- 16. El costo total por cada unidad de medicamento 
Select sum (a.cantidad*precioUnitario) as [Total], b.nombre from DetallePedido  a inner join Medicamento b
on a.idMedicamento = b.idMedicamento 
group by b.nombre order by b.nombre
--17. Los medicamentos que fueron entregados y la fecha de entrega 
select Medicamento.nombre, Pedido.fechaPedidoRecibido from Pedido full join Medicamento on Pedido.idMedicamento = Medicamento.idMedicamento
where fechaPedido is not null
--18. La hora de la emergenciasy la descripcion del procedimiento que se atendió  
select Urgencia.horaUrgencia, Procedimiento.descripcionProcedimiento from (Urgencia full join urgenciaProcedimiento 
on urgenciaProcedimiento.idUrgencia = Urgencia.idUrgencia) full join Procedimiento 
on  Procedimiento.idProcedimiento = urgenciaProcedimiento.idProcedimiento where horaUrgencia is not null
--19. La cantidad de Mujeres atendidas hoy 
select count (Paciente.idPaciente) as [ Mujeres atendidas ]from Paciente inner join Cita 
on Paciente.idPaciente = cita.idPaciente where paciente.genero = 'Femenino' and Cita.fecha_Cita = GETDATE()
--20. Pacientes que midan entre 1.70 y 1.90, pesen más de 50 kg  
select paciente.nombrePaciente, Paciente.apellidoPaterno, Paciente.apellidoMaterno, peso, talla 
from Paciente where (Paciente.talla between 1.70 and 1.90) and  (Paciente.peso>50) order by nombrePaciente
--21. El promedio del peso de los pacientes 
select avg(peso) as [El peso promedio es ]  from Paciente
--22. El total de emergencias atendidas 
Select count(idUrgencia) as [Emergencias Atendidas] from Urgencia where idUrgencia is not null

---Funciones
---Total de Empleados
create function totalPersonal() RETURNS int 
as begin 
	declare @aux int
	select @aux = COUNT(*) from Personal
	return @aux
end
select dbo.totalPersonal()
---Cantidad de pacientes en hospitalizacion
create function totalPacienteenHospitalizacion() returns int
as begin
	declare @aux int 
	select @aux = COUNT(*) from Hospitalizacion h inner join estadoHospitalizacion e on h.idEstadoHospitalizacion = e.idEstadoHospitalizacion
	where descripcion not in ('DE ALTA')
	return @aux
end 
select dbo.totalPacienteenHospitalizacion()
---Medicamentos segun el proveedor
create function dbo.medicamentossegunProveedor(@temp varchar(20)) returns table
as 
	return (select Medicamento.nombre, Medicamento.idMedicamento, stock,@temp as [Nombre Proveedor] from ((medicamentoProveedor inner join Medicamento on medicamentoProveedor.idMedicamento = Medicamento.idMedicamento) inner join Proveedor on medicamentoProveedor.idProveedor = Proveedor.idProveedor) where Proveedor.nombre = @temp)
go
select * from dbo.medicamentossegunProveedor('LabMedPeru SA.')
---Representaciones de los Proveedores
create function dbo.representantesProveedores() returns table
as 
	return (select p.idPersonaContacto,p.nombre,p.apellidoPaterno,p.apellidoMaterno,p.telefono,p.email,pr.nombre as [Proveedor] from PersonaContacto p inner join Proveedor pr on p.idPersonaContacto = pr.idPersonaContacto)
go
select *from dbo.representantesProveedores()
---Pacientes con Determinada Enfermedad
create function dbo.pacienteDiagnostico(@Enfermedad varchar(30)) returns table
as
	return (select p.nombrePaciente,concat(p.apellidoPaterno, ' ' ,p.apellidoMaterno) as [Apellidos],d.nombreDiagnostico from (Paciente p 
			inner join Cita a on (p.idPaciente = a.idPaciente) 
			inner join ConclusionCita b on (a.idConclusionCita = b.idConclusionCita)
			inner join DiagnosticoConclusionCita c on (b.idConclusionCita = c.idConclusionCita)
			inner join Diagnostico d on (c.idDiagnostico = d.idDiagnostico)) where d.nombreDiagnostico = @Enfermedad)
go
select * from dbo.pacienteDiagnostico('Esquizofrenia')
--- Personal que ha ingresado X fecha formato (AAAA-MM-DD)
create function dbo.personalxFecha(@fecha date) returns table
as
	return (
	select p.idPersonal,p.nombrePersonal from Personal p 
	inner join EntradaPersonal e on (p.idPersonal = e.idPersonal) where e.fechaEntrada = @fecha)
go
select * from dbo.personalxFecha('2019-06-17')
---Cantidad de Urgencia de X fecha formato (AAAA-MM-DD)
create function dbo.urgenciasXfecha(@fecha date) returns table
as
	return (select * from Urgencia where fechaUrgencia = @fecha)
go
select * from dbo.urgenciasXfecha('2018-06-15')
---
---historialClinicoXdni
create function dbo.historialClinicoXdni(@dni varchar(10)) returns table
as
	return(select b.idCita,d.nombrePersonal,c.nombrePaciente, b.fecha_Cita   from historialClinicoPaciente a
		inner join Cita b on(a.idCita = b.idCita)
		inner join Paciente c on(b.idPaciente = c.idPaciente) 
		inner join Personal d on (b.idPersonal = d.idPersonal)
		where c.idPaciente = @dni)
go
select * from dbo.historialClinicoXdni('09893036')
---Medicamentos con X presentacion
create function dbo.MedicamentosXPresentacion(@tipo varchar(15)) returns table
as
	return (select b.idMedicamento, b.nombre,b.cantidad,c.nombrePresentacion from medicamentoPresentacion a
inner join Medicamento b on (a.idMedicamento = b.idMedicamento)
inner join Presentacion c on (a.idPresentacion = c.idPresentacion) where a.idPresentacion = @tipo)
go
select * from dbo.MedicamentosXPresentacion('P156S')
---Medicamento con todos sus Componentes
create function dbo.MedicamentoComponentes(@medicamento varchar(15)) returns table
as
	return (select b.nombre,c.idComponente,c.nombreComponente, a.cantidad, c.descripcion from componenteMedicamento a
		inner join Medicamento b on (a.idMedicamento = b.idMedicamento)
		inner join Componente c on(a.idComponente = c.idComponente) where b.idMedicamento =@medicamento
	)
go
select* from dbo.MedicamentoComponentes('MDCMT8')
---Procedimiento
---Personal laborando en el hospital
CREATE PROCEDURE personal_lab_hosp
AS
Select nombrePersonal, fechaNacimiento, telefonoEmergencia
from Personal
Where idEstadoPersonal = 'Activo'
GO
EXEC personal_lab_hosp

--- Las camas que estan en uso
CREATE PROCEDURE camas_no_disponibles
AS
Select c.nroCama as 'Habitacion', p.nombrePaciente as 'Paciente'
from cama c inner join EstadoCama ec on c.idEstadoCama=ec.idEstadoCama 
full join Hospitalizacion h on h.idCama = c.idCama 
inner join Paciente p on h.idPaciente = p.idPaciente
where ec.descripcionEstadoCama = 'En uso' 
GO
EXEC camas_no_disponibles

---Medicamento caducados
CREATE PROCEDURE medicamentos_caducados
AS
Select m.nombre, m.marca
from Medicamento m inner join EstadoMedicamento em on m.idEstadoMedicamento = m.idEstadoMedicamento
where em.descripcionEstadoMedicamento = 'Caducado' and m.marca is not null
GO
EXEC medicamentos_caducados

---Personal de ingreso en un intervalo de tiempo
CREATE PROCEDURE personal_ingreso
AS
Select p.nombrePersonal, ep.horaEntrada, sp.horaSalida
from EntradaPersonal ep full join Personal p on ep.idPersonal=p.idPersonal full join SalidaPersonal sp on p.idPersonal=sp.idPersonal
Where ep.horaEntrada >= '9:00:00' and sp.horaSalida<='22:00:00'
GO
EXEC personal_ingreso

---Personas en las las habitaciones
CREATE PROCEDURE personas_habitacion
AS
Select distinct p.nombrePaciente, c.nroHabitacion
from Hospitalizacion h full join Paciente p on h.idPaciente = p.idPaciente full join cama c on h.idCama=c.idCama full join Habitacion hn on c.nroHabitacion=c.nroHabitacion
Where p.nombrePaciente is not null
GO
drop procedure personas_habitacion
EXEC personas_habitacion

---Paciente con su medicamento
CREATE PROCEDURE medicamento_paciente
AS
Select p.nombrePaciente, m.nombre
from recetaMedicaMedicamento rm full join Medicamento m on rm.idMedicamento = m.idMedicamento full join RecetaMedica rc on rc.idRecetaMedica = rm.idRecetaMedica full join Paciente p on rc.idPaciente = p.idPaciente
Where rm.cantidad > 2 order by p.nombrePaciente
GO
EXEC medicamento_paciente

---Medicamentos recibidos
CREATE PROCEDURE medicamentos_recibido
AS
Select m.nombre, p.fechaPedidoRecibido
From Pedido p full join Medicamento M on p.idMedicamento = m.idMedicamento
Where p.fechaPedido is not null
GO
EXEC medicamentos_recibido