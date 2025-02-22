// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function ablehnungSendenTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "ablehnung-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "ablehnung_erhalten_message",
          correlationKey: "ablehnung_erhalten_key",
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  