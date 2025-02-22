import { Camunda8 } from "@camunda8/sdk";
import path from "path";

const camunda = new Camunda8();
const zeebe = camunda.getZeebeGrpcApiClient();

async function main() {
  const deploy = await zeebe.deployResource({
    processFilename: path.join(process.cwd(), "src/bpmn/testing/start_event_demo.bpmn"),
  });
  console.log(
    `[Zeebe] Deployed demo process ${deploy.deployments[0].process.bpmnProcessId}`
  );
}

main();

async function startProcess() {
  const messageKey = "message_start_event";
  const correlationKey = "demo_key";

  await zeebe.publishMessage({
    name: messageKey,
    correlationKey: correlationKey,
    variables: { 
      angebot: 1000,
      textfield_summe_erhalten: "1000"
    },
    timeToLive: 60000, // 60 sec
  });

  console.log(`[Zeebe] Message Event '${messageKey}' wurde gesendet.`);
}

async function startWorker() {
  zeebe.createWorker({
    taskType: "service-task-demo",
    taskHandler: (job) => {
      const { angebot } = job.variables;

      console.log(`[Worker] Verarbeite Summe: ${angebot}`);

      return job.complete({
        output: { bestätigung: `Angebot in Höhe von ${angebot} wurde ausgegeben.` },
      });
    },
  });

  console.log("[Worker] Service Task Worker gestartet.");
}

startProcess()
startWorker()