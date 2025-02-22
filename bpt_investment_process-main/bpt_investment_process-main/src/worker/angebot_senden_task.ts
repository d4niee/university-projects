// worker: throw message

import { ZeebeGrpcClient } from "@camunda8/sdk/dist/zeebe";

// starting the process engine
export function angebotSendenTask(zeebe: ZeebeGrpcClient) {
    zeebe.createWorker({
      taskType: "angebot-senden-task",
      taskHandler: (job) => {
        return zeebe.publishMessage({
          name: "angebot_erhalten_message",
          correlationKey: "angebot_erhalten_key",
          timeToLive: 60000,
        }).then(() => job.complete());
      },
    });
}
  