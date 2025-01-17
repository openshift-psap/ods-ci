# Copyright 2020 kubeflow.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# source https://github.com/kubeflow/kfp-tekton/blob/master/samples/flip-coin/condition.py
from kfp import components, dsl


def random_num(low: int, high: int) -> int:
    """Generate a random number between low and high."""
    import random

    result = random.randint(low, high)
    print(result)
    return result


def flip_coin() -> str:
    """Flip a coin and output heads or tails randomly."""
    import random

    result = "heads" if random.randint(0, 1) == 0 else "tails"
    print(result)
    return result


def print_msg(msg: str):
    """Print a message."""
    print(msg)


@dsl.pipeline(
    name="conditional-execution-pipeline",
    description="Shows how to use dsl.Condition().",
)
def flipcoin_pipeline():
    flip_coin_op = components.create_component_from_func(
        flip_coin, base_image="registry.redhat.io/ubi8/python-39@sha256:3523b184212e1f2243e76d8094ab52b01ea3015471471290d011625e1763af61"
    )
    print_op = components.create_component_from_func(
        print_msg, base_image="registry.redhat.io/ubi8/python-39@sha256:3523b184212e1f2243e76d8094ab52b01ea3015471471290d011625e1763af61"
    )
    random_num_op = components.create_component_from_func(
        random_num, base_image="registry.redhat.io/ubi8/python-39@sha256:3523b184212e1f2243e76d8094ab52b01ea3015471471290d011625e1763af61"
    )

    flip = flip_coin_op()
    with dsl.Condition(flip.output == "heads"):
        random_num_head = random_num_op(0, 9)
        with dsl.Condition(random_num_head.output > 5):
            print_op("heads and %s > 5!" % random_num_head.output)
        with dsl.Condition(random_num_head.output <= 5):
            print_op("heads and %s <= 5!" % random_num_head.output)

    with dsl.Condition(flip.output == "tails"):
        random_num_tail = random_num_op(10, 19)
        with dsl.Condition(random_num_tail.output > 15):
            print_op("tails and %s > 15!" % random_num_tail.output)
        with dsl.Condition(random_num_tail.output <= 15):
            print_op("tails and %s <= 15!" % random_num_tail.output)
