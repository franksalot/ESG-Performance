execute('

SET NOCOUNT ON

DECLARE @SD date,
        @ED date,
        @QD date


SET @SD = ''2018-01-01''
SET @ED = getdate();
SET @QD = dateadd(mm, 3, @SD)

IF OBJECT_ID(''tempdb.dbo.#results'', ''U'') IS NOT NULL
DROP TABLE #results ;
Create Table #results
(
        QuarterDateEND     date NULL,
        Metric      decimal(10, 8),
        Metrictype    nvarchar(50)

)

While @SD <= @ED

Begin
INSERT INTO #results

  SELECT dateadd(mm, 3, @SD), (CAST(SUM(CASE WHEN b.acceptedDttm > DATEADD(dd,42,a.todttm) THEN 0 ELSE 1 END) as decimal(10,2)) / count(b.id)) As ''Bills'', ''%Final Bills Within 6 Weeks'' as ''MetricType''

      FROM Bill b

        INNER JOIN Account a on b.accountFk = a.id

              WHERE  b.acceptedDttm > @SD
	           	AND b.acceptedDttm <= @QD
		          AND b.finalFl = ''Y'' 
		          AND b.supersededFl = ''N''
	           	AND b.status = ''Accepted''
	           	AND a.cancelledDttm is null
	            AND a.toDttm < GETDATE()
	            AND EXISTS 

			                	(SELECT 1 

				                    	FROM Ticket t 

						                            inner join TicketDefinition td on t.ticketDefinitionFk = td.id
							                            AND td.keyPrefix = ''G4SCUSTLOSS''
						                            INNER JOIN TicketEntity te on t.id = te.ticketFk
						                            INNER JOIN EntityTbl e on te.entityTblFk = e.id
							                            AND e.entity = ''ACCOUNT''
						
						                                WHERE te.entityId = a.id)
		
						set @SD = dateadd(mm, 3, @SD)
						set @QD = dateadd(mm, 3, @SD)
						
						end;
						
						select * from #results
						
						')
						
