import { Camunda8 } from "@camunda8/sdk";
import path from "path";

const camunda = new Camunda8();
const zeebe = camunda.getZeebeGrpcApiClient();

// deploy process to camunda tasklist
async function deployProcess() {
  try {
    const deploy = await zeebe.deployResource({
      processFilename: path.join(process.cwd(), "src/bpmn/testing/start_event_demo_throwing.bpmn"),
    });
    console.log(`[Zeebe] Deployed Process '${deploy.deployments[0].process.bpmnProcessId}'`);
  } catch (error) {
    console.error(`[Zeebe] Error:`, error);
  }
}

// start the main proccess
async function startMain() {
  try {
    await zeebe.createProcessInstance({
      bpmnProcessId: "Process_abteilung_demo",
      variables: {
        investitionsSumme: 1000,
      },
    });

    console.log(`[Zeebe] 🚀 main process "abteilung" started`);
  } catch (error) {
    console.error(`[Zeebe] ❌ error:`, error);
  }
}

// worker: throw message
async function startThrowingMessageWorker() {
  zeebe.createWorker({
    taskType: "send_sum_to_auto",
    taskHandler: (job) => {
      const { investitionsSumme } = job.variables;

      console.log(`[Worker] send Summe: ${investitionsSumme}€`);

      return zeebe.publishMessage({
        name: "message_sum_received", // Muss exakt mit messageRef im BPMN übereinstimmen
        correlationKey: "investition_key",
        variables: {
          erhalteneSumme: investitionsSumme,
        },
        timeToLive: 60000,
      }).then(() => job.complete());
    },
  });

  console.log(`[Worker] 🔄 Worker for "summe senden" started.`);
}


// worker: service
async function startServiceWorker() {
  zeebe.createWorker({
    taskType: "service-task-demo",
    taskHandler: (job) => {
      const { erhalteneSumme } = job.variables;

      console.log(`[Worker] Summe ${erhalteneSumme}€ wird eingepflegt...`);

      return job.complete({
        output: { bestätigung: `Summe von ${erhalteneSumme} wurde gespeichert.` },
      });
    },
  });

  console.log(`[Worker] 🔄 Worker für "summe einpflegen" gestartet.`);
}

async function main() {
  await deployProcess();
  await startMain(); // or deploy by yourself

  // workers
  startThrowingMessageWorker();
  startServiceWorker();
}

main();
