Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'DAILY - Database File FreeSpace', @description=N'', @facet=N'DataFile', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>GE</OpType>
  <Count>2</Count>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>Subtract</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>Size</Name>
    </Attribute>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>UsedSpace</Name>
    </Attribute>
  </Function>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>Multiply</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>Size</Name>
    </Attribute>
    <Function>
      <TypeClass>Numeric</TypeClass>
      <FunctionType>Divide</FunctionType>
      <ReturnType>Numeric</ReturnType>
      <Count>2</Count>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>10</Value>
      </Constant>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>100</Value>
      </Constant>
    </Function>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id


Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'policy_ObjectSet_1', @facet=N'DataFile', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'policy_ObjectSet_1', @type_skeleton=N'Server/Database/FileGroup/File', @type=N'FILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/FileGroup/File', @level_name=N'File', @condition_name=N'', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/FileGroup', @level_name=N'FileGroup', @condition_name=N'', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0



Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'DAILY - Database File FreeSpace', @condition_name=N'DAILY - Database File FreeSpace', @policy_category=N'Daily Health Check', @description=N'Checks each database file for freespace based', @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'policy_ObjectSet_1'
Select @policy_id


