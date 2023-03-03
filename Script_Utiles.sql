1.- Obtener registro de personas 
a) Por PERS_CORREL (identificador único de paciente)
SELECT * FROM PERSONAS WHERE PERS_CORREL=4428525;
b) Por PERS_RUT(sin dígito verificador)
SELECT * FROM PERSONAS WHERE PERS_RUT=27562709;
c) Por PERS_PASAPORTE(para extranjeros)
SELECT * FROM PERSONAS WHERE PERS_PASAPORTE='588307873';
d) Por apellidos (siempre maýusculas)
SELECT * FROM PERSONAS WHERE PERS_APE_PATERNO='MENA' AND PERS_APE_MATERNO='FERNANDEZ';

2.- Cuando hay registros mal creado, estos tienen un "##1" en la columna PATNR. Este scritp lo actualiza para que se cree correctamente.
UPDATE PERSONAS SET PATNR=NULL WHERE PERS_CORREL=1; 

3.- Obtener registros de médicos
a) Por RUT (sin DV)
select * from medicos WHERE MEDICO_RUT=16287149;
b) Por PERS_CORREL
select * from medicos WHERE PERS_CORREL=940142;
c) Por código médico
select * from medicos WHERE MEDICO_COD=5843;


4.- Obtener definición de bloques de agendas vigentes para un médico
SELECT * FROM AGE_DEF_HORARIOS_SEMANAS
WHERE MEDICO_COD = 14086
AND (DHS_FECHA_VIGEN_HASTA >= TRUNC(SYSDATE) OR DHS_FECHA_VIGEN_HASTA IS NULL);

5.- Obtener todas las citas de CONSULTAS AMBULATORIAS de un paciente (incluso anuladas). Se busca por PERS_CORREL
SELECT CAM_ID,
  CAM_ASUNTO,
  AM.MEDICO_COD,
  M.MEDICO_NOMBRE,
  M.MEDICO_APE_PATERNO,
  M.MEDICO_APE_MATERNO,
  AGS.SERV_COD,
  AGS.SERV_DESCRIPCION,
  CAM_ESTADO,
  AM.CAM_EPISODIO_SAP,
  TO_CHAR(FEC_DIGITACION,'DD/MM/YYYY HH24:MI:SS') FEC_DIGITACION,
  TO_CHAR(FEC_ANULA,'DD/MM/YYYY HH24:MI:SS') FEC_ANULA,
  TO_CHAR(CAM_FECHA_HORA_DESDE,'DD/MM/YYYY HH24:MI:SS') CAM_FECHA_HORA_DESDE,
  TO_CHAR(CAM_HORA_LLEGADA,'DD/MM/YYYY HH24:MI:SS') CAM_HORA_LLEGADA,
  TO_CHAR(CAM_HORA_ATENCION,'DD/MM/YYYY HH24:MI:SS') CAM_HORA_ATENCION
FROM AGE_CITAS_AGENDAS_MEDICAS AM, MEDICOS M, AGE_BLOQUES_ATENCION BA, AGE_SERVICIOS AGS
WHERE AM.PERS_CORREL=990658
AND AM.MEDICO_COD = M.MEDICO_COD
AND BA.BAT_ID = AM.BAT_ID
AND BA.SERV_COD = AGS.SERV_COD
ORDER BY AM.CAM_FECHA_HORA_DESDE DESC;

6.- Revisar mensajería generada. Si MSG_PARAM es un valor de PERS_CORREL es mensajería asociada a un paciente. Si es valor de CAM_ID (Identificador único de cita) son los mensajes asociados a una cita.
SELECT MSG_CODE,MSG_PARAM,TO_CHAR(MSG_DATE,'DD/MM/YYYY HH24:MI:SS') FECHA,MSG_STATUS,MSG_RETRY_ITERATION,MSG_DETAILS,MSG_DATA FROM HL7_MESSAGES_OUT WHERE MSG_PARAM=4428525 ORDER BY MSG_DATE DESC;

7.- Validación de pago de cita (consulta ambulatoria)
a) Si es pagada por tótem el resultado es mayor a 0.
SELECT COUNT(*) FROM CV_CAJAVIRTUAL WHERE CV_CAJAVIRTUAL.CAM_ID = 28814185;
b) Si es pagada por caja SAP tiene valor.
SELECT AM.CAM_EPISODIO_SAP FROM AGE_CITAS_AGENDAS_MEDICAS AM WHERE AM.CAM_ID = 28814185;
c) Si es pagada por caja TyC el contador es mayor a 0.
SELECT COUNT(*) FROM CARGOS_CAB C, CARGOS_DET D WHERE C.CAM_ID = 28814185 AND C.CARGO_CORREL = D.CARGO_CORREL AND D.E_REGISTRO_COD_CAN = '9' AND C.E_REGISTRO_COD = '1' AND D.E_REGISTRO_COD = '1';

select distinct vs.sql_text, vs.sharable_mem,
vs.persistent_mem, vs.runtime_mem, vs.sorts,
vs.executions, vs.parse_calls, vs.module,
vs.buffer_gets, vs.disk_reads, vs.version_count,
vs.users_opening, vs.loads,
to_char(to_date(vs.first_load_time,
'YYYY-MM-DD/HH24:MI:SS'),'MM/DD HH24:MI:SS') first_load_time,
rawtohex(vs.address) address, vs.hash_value hash_value ,
rows_processed , vs.command_type, vs.parsing_user_id ,
OPTIMIZER_MODE , au.USERNAME parseuser
from v$sqlarea vs , all_users au
--where (parsing_user_id != 0) AND (au.user_id(+)=vs.parsing_user_id)
--where au.user_id = 8944
where au.username = 'FBERRIOSC' 
and (executions >= 1) 
--order by buffer_gets/executions desc;
--order BY vs.last_active_time desc;
AND to_char(to_date(first_load_time,
'YYYY-MM-DD/HH24:MI:SS'),'DD/MM/YY')= '13/01/23'
ORDER BY 14 DESC;