<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Job_Posting_Approved_Alert</fullName>
        <description>Job Posting Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Job_Approval_Templates/Job_Posting_Approved</template>
    </alerts>
    <alerts>
        <fullName>Job_Submitted_for_Approval_Alert</fullName>
        <description>Job Submitted for Approval Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Job_Approval_Templates/Job_Submitted_for_Approval</template>
    </alerts>
    <alerts>
        <fullName>Job_recalled_from_Approval_queue_alert</fullName>
        <description>Job recalled from Approval queue alert</description>
        <protected>false</protected>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Job_Approval_Templates/Job_Recalled_form_Approval</template>
    </alerts>
    <alerts>
        <fullName>Job_rejected_Alert</fullName>
        <description>Job rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Job_Approval_Templates/Job_Posting_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Status_for_Correction</fullName>
        <field>Job_Status__c</field>
        <literalValue>Sent back for Correction</literalValue>
        <name>Update Status for Correction</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_for_Publishing</fullName>
        <field>Job_Status__c</field>
        <literalValue>Ready to be Published</literalValue>
        <name>Update Status for Publishing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Draft</fullName>
        <field>Job_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Update Status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_In_Review</fullName>
        <field>Job_Status__c</field>
        <literalValue>In Review</literalValue>
        <name>Update Status to In Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
