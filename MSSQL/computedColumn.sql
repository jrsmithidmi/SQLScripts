ALTER TABLE [dbo].[Insured]
    ADD [phoneDigitOnly] AS CAST((replace(replace(replace(replace(replace([phone],'(',''),')',''),'X',''),'-',''),' ','')) AS BIGINT) PERSISTED
GO
ALTER TABLE [dbo].[Insured]
    ADD [phone2DigitOnly] AS CAST((replace(replace(replace(replace(replace([phone2],'(',''),')',''),'X',''),'-',''),' ','')) AS BIGINT) PERSISTED
GO
ALTER TABLE [dbo].[Insured]
    ADD [faxDigitOnly] AS CAST((replace(replace(replace(replace(replace([fax],'(',''),')',''),'X',''),'-',''),' ','')) AS BIGINT) PERSISTED
GO
ALTER TABLE [dbo].[Insured]
    ADD [tollFreeDigitOnly] AS CAST((replace(replace(replace(replace(replace([tollFree],'(',''),')',''),'X',''),'-',''),' ','')) AS BIGINT) PERSISTED
GO
ALTER TABLE [dbo].[Insured]
    ADD [pagerDigitOnly] AS CAST((replace(replace(replace(replace(replace([pager],'(',''),')',''),'X',''),'-',''),' ','')) AS BIGINT) PERSISTED
GO