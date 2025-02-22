// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function startThrowingMessageWorker(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "invest_message_send",
      taskHandler: (job) => {
        console.log(`[Worker] sending start event...`);
        return zeebe.publishMessage({
          name: "invest_message_received",
          correlationKey: "",
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
    console.log(`[Worker] 🔄 Worker for "start department event" started.`);
}
  