select /*+   index(ei IDX_ENIAX_PRG_EVENTO)  index(am CAM_PK ) */ ei.prg_correl, am.cam_id, am.fec_modificacion , f.func_rut AS FUNCIONARIO,
decode(f.func_rut,'720','WEB','PRESENCIAL') AS CANAL
from eniax_interfaz ei, age_citas_agendas_medicas am, funcionarios f
where ei.cam_id = am.cam_id
and to_char(am.cam_usr_modifica) = to_char(f.func_rut)
and ei.prg_evento = 5
and ei.prg_estado = 0
AND NOT EXISTS (SELECT 1
                  FROM eniax_interfaz ei2
                 WHERE ei2.CAM_ID = ei.CAM_ID
                   AND ei2.prg_estado = 0
                   AND ei2.PRG_CORREL < ei.PRG_CORREL )order by am.fec_modificacion desc;
                   
                   
                   
 select uni.tiempo_minutos, uni.cam_id, uni.pago_cita, nvl(uni.error_tbk, 'vacia') as error_tbk
from
(select /*+ full(b) index(a AGE_CITAS_AGENDAS_MEDICAS_I1) */ trunc((sysdate-a.fec_digitacion)*1440) tiempo_minutos,a.cam_id,
       b.bat_id,
       a.pers_correl,
       m.medico_cod,
       m.medico_nombre,
       m.medico_ape_paterno,
       m.medico_ape_materno,
       p.pers_rut rut_paciente,
       p.pers_dv dv_paciente,
       p.pers_pasaporte pasaporte,
       a.cam_asunto paciente,
       a.cam_fecha_hora_desde,
       a.fec_digitacion,
       a.cam_tipo_agendamiento,
       a.cam_hora_llegada,
       obtiene_contacto_persona(a.pers_correl,'HABI') habitual,
       obtiene_contacto_persona(a.pers_correl,'CELU') celular,
       obtiene_contacto_persona(a.pers_correl,'MAIL') mail_reserva,
       obtiene_contacto_persona(a.pers_correl,'MICLC') mail_miclc,
       nvl2((select t.tbk_respuesta from transacciones_cons t where t.id_comercio_clc = 'TELEMED_CLC' and t.respuesta_cod=0 and a.cam_id = t.id_negocio),'SI','NO') pago_cita,--,
       (select t.tbk_respuesta from transacciones_cons t where t.id_comercio_clc = 'TELEMED_CLC' and a.cam_id = t.id_negocio and rownum = 1) error_tbk
  from age_citas_agendas_medicas a,
       age_bloques_atencion      b,
       personas                  p,
       medicos                   m
where a.bat_id = b.bat_id
   and b.serv_cod in('139','1390','211')
   and a.pers_correl=p.pers_correl
   and a.medico_cod = b.medico_cod
   and a.medico_cod = m.medico_cod
   and trunc(b.bat_fecha) between  trunc(sysdate) and trunc(sysdate)+60--and b.bat_fecha between trunc(sysdate) + 1/1440 and trunc(sysdate)+60 --and trunc(sysdate)+60 --to_date('16-04-2020','dd-mm-yyyy')
   and a.cam_estado = 'N'
   and a.medico_cod = b.medico_cod
   and a.amed_cod in(100, 10222, 10223)) uni
WHERE uni.pago_cita = 'NO';                   



-- CARESTREAM GENERA MFN --
SELECT M.PERS_CORREL,
    M.T_MEDICO_COD,
    LPAD(M.MEDICO_COD,6,0) MEDICO_COD,
    M.MEDICO_NOMBRE,
    M.MEDICO_APE_PATERNO,
    M.MEDICO_APE_MATERNO,
    V.VAL_DOMINIO_DESC TIPO_MEDICO,
    (SELECT PERS_CONTACTO_VALOR
    FROM PERSONAS_CONTACTOS
    WHERE PERS_CORREL  = M.PERS_CORREL
    AND T_CONTACTO_COD = 'FMAIL'
    ) FMAIL
  FROM MEDICOS M,
    VALORES_DOMINIO V
  WHERE V.VAL_DOMINIO_COD = M.T_MEDICO_COD
  AND V.DOMINIO_NOMBRE    = 'TIPO MEDICO' 
  AND M.T_MEDICO_COD IN ('AC','CO','IN','SE','SO','RSU','RR','RA','BECADO','AS','ST')
  AND M.MEDICO_COD >0 order by 1 DESC;
  
  
  
 --- DBREADER AGMED RECEPCION --- 
  SELECT /*+RULE*/ MSG_DATA, MSG_PARAM, MSG_CODE, MSG_STATUS, MSG_CORREL, TO_CHAR(MSG_DATE,'YYYY-MM-DD HH24:MI:SS') AS MSG_DATE
FROM
      HL7_MESSAGES_OUT  
WHERE
(	
   ( -- Creacion de citas del dia
      MSG_STATUS IN ('C','E') 
	  AND  MSG_CODE  IN ( 'CERNER_SIU_S12', 'CERNER_SIU_S14', 'CERNER_SIU_S15') 
	  AND (
	      SELECT AM.CAM_FECHA_HORA_DESDE FROM AGE_CITAS_AGENDAS_MEDICAS AM WHERE AM.CAM_ID = MSG_PARAM 
	      ) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE)+1
	)   
    OR 
	(          
	  MSG_STATUS IN ('C','E') 
	  AND MSG_CODE IN ('A01_AGENDA_CERNER', 'CERNER_SIU_S14_LLEGO') 
	  AND (
	        SELECT AM.CAM_HORA_LLEGADA FROM AGE_CITAS_AGENDAS_MEDICAS AM WHERE AM.CAM_ID = MSG_PARAM
	      ) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE)+1 
	 )
)
AND (    -- Servicios NO estan el piloto
    SELECT AGS.SERV_COD FROM AGE_CITAS_AGENDAS_MEDICAS AM, AGE_BLOQUES_ATENCION BA, AGE_SERVICIOS AGS 
    WHERE BA.BAT_ID     = AM.BAT_ID AND BA.SERV_COD = AGS.SERV_COD AND AM.CAM_ID   = MSG_PARAM
    ) NOT IN (SELECT PAR_VALOR_NUM  FROM AGE_PARAMETROS WHERE PAR_CODIGO = 176)
ORDER BY MSG_CORREL;



---1.- Obtener registro de personas ---
---a) Por PERS_CORREL (identificador único de paciente) --
SELECT * FROM PERSONAS WHERE PERS_CORREL=4428525;

--b) Por PERS_RUT(sin dígito verificador)
SELECT * FROM PERSONAS WHERE PERS_RUT=27562709;

---c) Por PERS_PASAPORTE(para extranjeros)
SELECT * FROM PERSONAS WHERE PERS_PASAPORTE='588307873';

---d) Por apellidos (siempre maýusculas)
SELECT * FROM PERSONAS WHERE PERS_APE_PATERNO='MENA' AND PERS_APE_MATERNO='FERNANDEZ';

SELECT * FROM PERSONAS WHERE PERS_APE_PATERNO='CUEVAS' and PERS_NOMBRE like 'LUIS %';



SELECT * FROM PERSONAS WHERE PERS_APE_PATERNO='CUEVAS';

---2.- Cuando hay registros mal creado, estos tienen un "##1" en la columna PATNR. Este scritp lo actualiza para que se cree correctamente. ---
UPDATE PERSONAS SET PATNR=NULL WHERE PERS_CORREL=1; 

SELECT * FROM PERSONAS WHERE PATNR = '##1'; 


SELECT COUNT(*) FROM PERSONAS WHERE PATNR = '##1'; 

 --3.- Obtener registros de médicos --
--a) Por RUT (sin DV)--
select * from medicos WHERE MEDICO_RUT=16287149;

--b) Por PERS_CORREL  ---
select * from medicos WHERE PERS_CORREL=940142;

---c) Por código médico ---
select * from medicos WHERE MEDICO_COD=5843;


---4.- Obtener definición de bloques de agendas vigentes para un médico --
SELECT * FROM AGE_DEF_HORARIOS_SEMANAS
WHERE MEDICO_COD = 14086
AND (DHS_FECHA_VIGEN_HASTA >= TRUNC(SYSDATE) OR DHS_FECHA_VIGEN_HASTA IS NULL);

--5.- Obtener todas las citas de CONSULTAS AMBULATORIAS de un paciente (incluso anuladas). Se busca por PERS_CORREL --

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

--6.- Revisar mensajería generada. Si MSG_PARAM es un valor de PERS_CORREL es mensajería asociada a un paciente. Si es valor de CAM_ID (Identificador único de cita) son los mensajes asociados a una cita. --
SELECT MSG_CODE,MSG_PARAM,TO_CHAR(MSG_DATE,'DD/MM/YYYY HH24:MI:SS') FECHA,MSG_STATUS,MSG_RETRY_ITERATION,MSG_DETAILS,MSG_DATA FROM HL7_MESSAGES_OUT WHERE MSG_PARAM=4428525 ORDER BY MSG_DATE DESC;

-- Validación de pago de cita (consulta ambulatoria) -- 
--a) Si es pagada por tótem el resultado es mayor a 0.--
SELECT COUNT(*) FROM CV_CAJAVIRTUAL WHERE CV_CAJAVIRTUAL.CAM_ID = 28814185;

--b) Si es pagada por caja SAP tiene valor. --
SELECT AM.CAM_EPISODIO_SAP FROM AGE_CITAS_AGENDAS_MEDICAS AM WHERE AM.CAM_ID = 28814185;

--c) Si es pagada por caja TyC el contador es mayor a 0.
SELECT COUNT(*) FROM CARGOS_CAB C, CARGOS_DET D WHERE C.CAM_ID = 28814185 AND C.CARGO_CORREL = D.CARGO_CORREL AND D.E_REGISTRO_COD_CAN = '9' AND C.E_REGISTRO_COD = '1' AND D.E_REGISTRO_COD = '1';
