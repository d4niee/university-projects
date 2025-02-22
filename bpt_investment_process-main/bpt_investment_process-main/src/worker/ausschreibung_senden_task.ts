// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function ausschreibungSendenTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "ausschreibung-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "ausschreibung_erhalten_message",
          correlationKey: "ausschreibung_erhalten_key",
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  