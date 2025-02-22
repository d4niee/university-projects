import { Camunda8 } from "@camunda8/sdk";
import { ResourceType } from "./ressource_type"
import path from "path";
import fs from "fs";

// workers
import { startThrowingMessageWorker } from "./worker/invest_message_send_task";
import { ausschreibungSendenTask } from "./worker/ausschreibung_senden_task";
import { ablehnungSendenTask } from "./worker/ablehnung_senden_task";
import { startThrowingMessageSupplierWorker } from "./worker/supplier_message_send_task";
import { ablehnungAusschreibungLieferantSendenTask } from "./worker/ausschreibung_lieferant_absage_senden_task";
import { ablehnungAngebotLieferantSendenTask } from "./worker/angebot_absage_lieferant_senden_task";
import { zusageAngebotLieferantSendenTask } from "./worker/angebot_zusage_lieferant_senden_task";


const camunda = new Camunda8();
const zeebe = camunda.getZeebeGrpcApiClient();

async function startProcess() {
  try {
    await zeebe.createProcessInstance({
      bpmnProcessId: "Process_department",
      variables: {
        processName: "Process_department",
      },
    });
    console.log(`[Zeebe] 🚀 main process "Process_department" started`);
  } catch (error) {
    console.error(`[Zeebe] ❌ error starting process:`, error);
  }
  console.log("\n-------------------------------------------")
  console.log("✅ Prozess gestartet!")
  console.log("Tasklist: http://localhost:8082/tasklist")
  console.log("Operate: http://localhost:8081/operate")
  console.log("-------------------------------------------")
}

async function deployResource(resourceType: ResourceType): Promise<void> {
  const formsDir = path.join(process.cwd(), "src/Forms");
  const dmnDir = path.join(process.cwd(), "src/DMN");
  const formFiles = fs.readdirSync(formsDir).filter(file => file.endsWith(".form"));
  const dmnFiles = fs.readdirSync(dmnDir).filter(file => file.endsWith(".dmn"));

  if (!Object.values(ResourceType).includes(resourceType)) {
    console.error(`[Zeebe] Ungültiger Ressourcentyp: ${resourceType}`);
    return;
  }
  if (resourceType == ResourceType.PROCESS) {
    let deploy = await zeebe.deployResource({
      processFilename: path.join(process.cwd(), "src/bpmn/main.bpmn"),
    });
    console.log(
      `[Zeebe] 🚀 Deployed ${resourceType} with ID: ${deploy.deployments[0].process.bpmnProcessId}`
    );
  } else if (resourceType == ResourceType.FORM) {
    for (const file of formFiles) {
      await zeebe.deployResource({
        processFilename: path.join(formsDir, file),
      });
      console.log(`[Zeebe] 🚀 Deployed FORM: ${file}`);
    }
  } else if (resourceType === ResourceType.DMN) {
    for (const file of dmnFiles) {
      await zeebe.deployResource({
        processFilename: path.join(dmnDir, file),
      });
      console.log(`[Zeebe] 🚀 Deployed DMN: ${file}`);
    }
  }
}

async function deployAndStart() {
  await deployResource(ResourceType.PROCESS);
  await deployResource(ResourceType.FORM);
  await deployResource(ResourceType.DMN);

  // Start the main process after all deployments are completed
  await startProcess();
}

deployAndStart().then(()=> {
  // Start worker after process deployment
  startThrowingMessageWorker(zeebe);
  ausschreibungSendenTask(zeebe);
  ablehnungSendenTask(zeebe);
  startThrowingMessageSupplierWorker(zeebe);
  ablehnungAusschreibungLieferantSendenTask(zeebe);
  ablehnungAngebotLieferantSendenTask(zeebe);
  zusageAngebotLieferantSendenTask(zeebe)
});
