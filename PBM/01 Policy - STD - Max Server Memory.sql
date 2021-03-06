Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'STD - Max Server Memory', @description=N'', @facet=N'IServerConfigurationFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>NE</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Numeric</TypeClass>
    <Name>MaxServerMemory</Name>
  </Attribute>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>2147483647</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id


Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'STD - Max Memory_ObjectSet', @facet=N'IServerConfigurationFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'STD - Max Memory_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id




Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'STD - Max Server Memory', @condition_name=N'STD - Max Server Memory', @policy_category=N'Standard Configuration Check', @description=N'Checks that the Max Server memory is NOT at the default value', @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'STD - Max Memory_ObjectSet'
Select @policy_id


