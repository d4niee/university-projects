// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function zusageSendenTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "zusage-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "zusage_erhalten_message",
          correlationKey: "zusage_erhalten_key",
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  